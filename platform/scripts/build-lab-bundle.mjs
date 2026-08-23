import { createHash } from 'node:crypto';
import { createWriteStream } from 'node:fs';
import { mkdir, readFile, readdir, rename, rm, stat, writeFile } from 'node:fs/promises';
import { dirname, join, relative, resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';

import { ZipArchive } from 'archiver';

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const platformDirectory = resolve(scriptDirectory, '..');
const repositoryDirectory = resolve(platformDirectory, '..');
const downloadsDirectory = join(platformDirectory, 'public', 'downloads');
const archivePath = join(downloadsDirectory, 'dart_lab_starter.zip');
const manifestPath = join(downloadsDirectory, 'dart_lab_starter.manifest.json');
const fixedArchiveDate = new Date('2000-01-01T00:00:00.000Z');

const excludedDirectories = new Set([
  '.dart_tool',
  '.idea',
  '.vscode',
  'build',
  'coverage',
  'soluciones',
]);
const excludedFiles = new Set(['.DS_Store', '.packages']);
const excludedStarterPaths = new Set([
  'dart_lab/tool/fixtures',
  'dart_lab/tool/verify_reference.dart',
]);
const requiredEntries = [
  '.fvmrc',
  'LEEME.md',
  'METODO.md',
  'tool/preflight.sh',
  'dart_lab/lab',
  'dart_lab/pubspec.yaml',
  'dart_lab/pubspec.lock',
  'dart_lab/bin/m01_hola.dart',
  'dart_lab/bin/lab.dart',
  'dart_lab/test/public_contract_test.dart',
];
const excludedEntries = [
  'dart_lab/tool/verify_reference.dart',
  'dart_lab/tool/fixtures/mutants.json',
];
const excludedPrefixes = ['dart_lab/soluciones/'];

function toArchivePath(value) {
  return value.split(sep).join('/');
}

function shouldExclude(relativePath, isDirectory) {
  const normalizedPath = toArchivePath(relativePath);
  const segments = relativePath.split(sep);
  if (isDirectory && segments.some((segment) => excludedDirectories.has(segment))) return true;
  return (
    [...excludedStarterPaths].some(
      (excludedPath) =>
        normalizedPath === excludedPath || normalizedPath.startsWith(`${excludedPath}/`),
    ) ||
    segments.some((segment) => excludedDirectories.has(segment)) ||
    excludedFiles.has(segments.at(-1))
  );
}

async function collectFiles(sourceDirectory, destinationDirectory) {
  const files = [];
  const entries = await readdir(sourceDirectory, { withFileTypes: true });
  entries.sort((left, right) => left.name.localeCompare(right.name, 'en'));

  for (const entry of entries) {
    const sourcePath = join(sourceDirectory, entry.name);
    const destinationPath = join(destinationDirectory, entry.name);
    const relativePath = relative(repositoryDirectory, sourcePath);

    if (entry.isSymbolicLink()) {
      throw new Error(`El starter no admite enlaces simbólicos: ${relativePath}`);
    }
    if (shouldExclude(relativePath, entry.isDirectory())) continue;

    if (entry.isDirectory()) {
      files.push(...(await collectFiles(sourcePath, destinationPath)));
    } else if (entry.isFile()) {
      files.push({ sourcePath, destinationPath: toArchivePath(destinationPath) });
    }
  }

  return files;
}

async function assertSourceFile(path) {
  const metadata = await stat(path);
  if (!metadata.isFile()) throw new Error(`Falta un archivo requerido para el starter: ${path}`);
}

async function createArchive(files, outputPath) {
  const output = createWriteStream(outputPath, { flags: 'wx' });
  const archive = new ZipArchive({ zlib: { level: 9 } });
  const completed = new Promise((resolvePromise, rejectPromise) => {
    output.once('close', resolvePromise);
    output.once('error', rejectPromise);
    archive.once('error', rejectPromise);
    archive.on('warning', (error) => {
      if (error.code === 'ENOENT') rejectPromise(error);
      else console.warn(error.message);
    });
  });

  archive.pipe(output);
  archive.append(
    `# Starter Dart Lab\n\nEste ZIP contiene el laboratorio Dart sin soluciones.\n\nDesde esta carpeta:\n\n\`\`\`sh\n./tool/preflight.sh\ncd dart_lab\nfvm dart pub get --enforce-lockfile\nfvm dart run bin/m01_hola.dart\n\`\`\`\n\nEmpieza con D00 en la plataforma. Usa \`./lab next\` cuando la lección D01 te indique comenzar los contratos. Lee \`METODO.md\` antes de consultar una solución externa.\n`,
    { name: 'LEEME.md', date: fixedArchiveDate, mode: 0o644 },
  );

  for (const file of files) {
    const metadata = await stat(file.sourcePath);
    archive.file(file.sourcePath, {
      name: file.destinationPath,
      date: fixedArchiveDate,
      mode: metadata.mode & 0o777,
    });
  }

  await archive.finalize();
  await completed;
}

async function replaceFile(tempPath, targetPath) {
  await rm(targetPath, { force: true });
  await rename(tempPath, targetPath);
}

async function main() {
  const fvmConfigPath = join(repositoryDirectory, '.fvmrc');
  const methodPath = join(repositoryDirectory, 'METODO.md');
  const preflightPath = join(repositoryDirectory, 'tool', 'preflight.sh');
  const dartLabPath = join(repositoryDirectory, 'dart_lab');
  await Promise.all([
    assertSourceFile(fvmConfigPath),
    assertSourceFile(methodPath),
    assertSourceFile(preflightPath),
  ]);

  const files = [
    { sourcePath: fvmConfigPath, destinationPath: '.fvmrc' },
    { sourcePath: methodPath, destinationPath: 'METODO.md' },
    { sourcePath: preflightPath, destinationPath: 'tool/preflight.sh' },
    ...(await collectFiles(dartLabPath, 'dart_lab')),
  ];
  files.sort((left, right) => left.destinationPath.localeCompare(right.destinationPath, 'en'));

  const archiveEntries = new Set(['LEEME.md', ...files.map((file) => file.destinationPath)]);
  for (const requiredEntry of requiredEntries) {
    if (!archiveEntries.has(requiredEntry)) {
      throw new Error(`Falta una entrada requerida en el starter: ${requiredEntry}`);
    }
  }
  for (const excludedEntry of excludedEntries) {
    if (archiveEntries.has(excludedEntry)) {
      throw new Error(`El starter contiene una entrada privada: ${excludedEntry}`);
    }
  }
  for (const excludedPrefix of excludedPrefixes) {
    if ([...archiveEntries].some((entry) => entry.startsWith(excludedPrefix))) {
      throw new Error(`El starter contiene una ruta privada: ${excludedPrefix}`);
    }
  }

  await mkdir(downloadsDirectory, { recursive: true });
  const tempArchivePath = `${archivePath}.${process.pid}.tmp`;
  const tempManifestPath = `${manifestPath}.${process.pid}.tmp`;
  await rm(tempArchivePath, { force: true });

  try {
    await createArchive(files, tempArchivePath);
    const bytes = await readFile(tempArchivePath);
    const manifest = {
      schemaVersion: 1,
      archive: 'dart_lab_starter.zip',
      sha256: createHash('sha256').update(bytes).digest('hex'),
      bytes: bytes.byteLength,
      fileCount: files.length + 1,
      excludesSolutions: true,
      requiredEntries,
      excludedEntries,
      excludedPrefixes,
      flutterVersion: '3.47.1',
      dartVersion: '3.13.x',
    };

    await writeFile(tempManifestPath, `${JSON.stringify(manifest, null, 2)}\n`, 'utf8');
    await replaceFile(tempArchivePath, archivePath);
    await replaceFile(tempManifestPath, manifestPath);
    console.log(
      `Starter creado: ${relative(repositoryDirectory, archivePath)} (${manifest.bytes} bytes, ${manifest.fileCount} archivos)`,
    );
  } catch (error) {
    await Promise.all([
      rm(tempArchivePath, { force: true }),
      rm(tempManifestPath, { force: true }),
    ]);
    throw error;
  }
}

await main();
