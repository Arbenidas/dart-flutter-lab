import { readdir, readFile, stat } from 'node:fs/promises';
import { basename, join, relative, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

interface LabReferenceInput {
  workspace: string;
  targetPath: string;
}

export interface CanonicalReference {
  label: string;
  code: string;
  language: 'dart' | 'text';
}

const repositoryRoot = resolve(fileURLToPath(new URL('../../../', import.meta.url)));
const allowedWorkspaces = new Set(['dart_lab', 'flutter_lab']);

async function dartFilesWithin(directory: string): Promise<string[]> {
  const entries = await readdir(directory, { withFileTypes: true });
  const files: string[] = [];
  for (const entry of entries.sort((left, right) => left.name.localeCompare(right.name))) {
    const path = join(directory, entry.name);
    if (entry.isDirectory()) files.push(...(await dartFilesWithin(path)));
    if (entry.isFile() && entry.name.endsWith('.dart')) files.push(path);
  }
  return files;
}

export async function loadCanonicalReference(
  lab: LabReferenceInput | undefined,
): Promise<CanonicalReference | undefined> {
  if (!lab || !allowedWorkspaces.has(lab.workspace) || lab.targetPath.includes('..')) {
    return undefined;
  }

  const workspaceRoot = resolve(repositoryRoot, lab.workspace);
  const learnerTarget = resolve(workspaceRoot, lab.targetPath);
  if (!learnerTarget.startsWith(`${workspaceRoot}/`)) return undefined;

  const canonicalTarget =
    lab.workspace === 'dart_lab' && lab.targetPath.startsWith('lib/')
      ? resolve(workspaceRoot, 'soluciones', basename(lab.targetPath))
      : learnerTarget;

  try {
    const targetStat = await stat(canonicalTarget);
    if (targetStat.isFile()) {
      return {
        label: relative(repositoryRoot, canonicalTarget),
        code: await readFile(canonicalTarget, 'utf8'),
        language: canonicalTarget.endsWith('.dart') ? 'dart' : 'text',
      };
    }

    if (targetStat.isDirectory()) {
      const files = (await dartFilesWithin(canonicalTarget)).slice(0, 6);
      const sections = await Promise.all(
        files.map(
          async (file) => `// ${relative(repositoryRoot, file)}\n${await readFile(file, 'utf8')}`,
        ),
      );
      return {
        label: `${relative(repositoryRoot, canonicalTarget)}/ (${files.length} archivos)`,
        code: sections.join('\n\n').slice(0, 30_000),
        language: 'dart',
      };
    }
  } catch {
    return undefined;
  }

  return undefined;
}
