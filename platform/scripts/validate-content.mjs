import { access, readFile, readdir } from 'node:fs/promises';
import { dirname, extname, isAbsolute, join, relative, resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';

import { parseDocument } from 'yaml';

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const platformDirectory = resolve(scriptDirectory, '..');
const repositoryDirectory = resolve(platformDirectory, '..');
const contentDirectory = join(platformDirectory, 'src', 'content');
const moduleIdPattern = /^(D(?:0[0-9]|1[0-5])|F0[0-6])$/;
const lessonIdPattern = /^(D(?:0[0-9]|1[0-5])|F0[0-6])-L\d{2}$/;
const activityKinds = new Set(['attempt', 'evidence', 'source', 'judgment']);
const lessonKinds = new Set(['concepto', 'taller', 'proyecto']);
const requiredMovements = {
  taller: ['attempt', 'evidence', 'source', 'judgment'],
  concepto: ['attempt', 'source', 'judgment'],
  proyecto: ['attempt', 'evidence', 'judgment'],
};
const lessonKindsThatNeedLab = new Set(['taller', 'proyecto']);
const sessionMinuteBudget = 90;
const movementLabels = {
  attempt: 'Intento',
  evidence: 'Evidencia',
  source: 'Fuente',
  judgment: 'Criterio',
};
const officialDocumentationHosts = new Set([
  'api.dart.dev',
  'api.flutter.dev',
  'dart.dev',
  'docs.flutter.dev',
  'pub.dev',
]);
const validStatuses = new Set(['available', 'preview', 'roadmap']);
const unsafeCommandCharacters = /[;&|<>`\n\r]/;
const errors = [];
const warnings = [];

function report(target, context, message) {
  target.push(`${context}: ${message}`);
}

function asArray(value) {
  return Array.isArray(value) ? value : [];
}

function hasText(value) {
  return typeof value === 'string' && value.trim().length > 0;
}

function uniqueValues(values) {
  return new Set(values).size === values.length;
}

function validateUnique(entries, selector, label) {
  const seen = new Map();
  for (const entry of entries) {
    const value = selector(entry);
    if (!hasText(value)) continue;
    if (seen.has(value))
      report(
        errors,
        entry.file,
        `${label} duplicado «${value}»; también aparece en ${seen.get(value)}`,
      );
    else seen.set(value, entry.file);
  }
}

async function readJsonCollection(directoryName) {
  const directory = join(contentDirectory, directoryName);
  const filenames = (await readdir(directory)).filter((name) => extname(name) === '.json').sort();
  return Promise.all(
    filenames.map(async (filename) => {
      const path = join(directory, filename);
      const file = relative(platformDirectory, path);
      try {
        return { file, filename, data: JSON.parse(await readFile(path, 'utf8')) };
      } catch (error) {
        report(
          errors,
          file,
          `JSON inválido (${error instanceof Error ? error.message : String(error)})`,
        );
        return { file, filename, data: {} };
      }
    }),
  );
}

async function readLessons() {
  const directory = join(contentDirectory, 'lessons');
  const filenames = (await readdir(directory)).filter((name) => extname(name) === '.md').sort();
  return Promise.all(
    filenames.map(async (filename) => {
      const path = join(directory, filename);
      const file = relative(platformDirectory, path);
      const source = await readFile(path, 'utf8');
      const match = source.match(/^---\r?\n([\s\S]*?)\r?\n---(?:\r?\n|$)/);
      if (!match) {
        report(errors, file, 'falta un bloque de frontmatter YAML delimitado por ---');
        return { file, filename, data: {} };
      }

      const document = parseDocument(match[1], { uniqueKeys: true });
      for (const issue of document.errors) report(errors, file, `YAML inválido (${issue.message})`);
      for (const issue of document.warnings)
        report(warnings, file, `advertencia YAML (${issue.message})`);
      return { file, filename, data: document.errors.length === 0 ? document.toJS() : {} };
    }),
  );
}

function validateRequiredFields(entries, fields) {
  for (const entry of entries) {
    for (const field of fields) {
      if (!hasText(entry.data[field]))
        report(errors, entry.file, `«${field}» debe ser texto no vacío`);
    }
    if (!Number.isInteger(entry.data.order) || entry.data.order < 0)
      report(errors, entry.file, '«order» debe ser un entero no negativo');
    if (entry.data.status && !validStatuses.has(entry.data.status))
      report(errors, entry.file, `status no permitido: ${entry.data.status}`);
  }
}

function validateOrder(entries, groupSelector, label) {
  const groups = new Map();
  for (const entry of entries) {
    const group = groupSelector(entry);
    if (!groups.has(group)) groups.set(group, []);
    groups.get(group).push(entry);
  }
  for (const [group, groupEntries] of groups) {
    const orders = groupEntries.map((entry) => entry.data.order).filter(Number.isInteger);
    if (!uniqueValues(orders)) report(errors, label, `hay valores order duplicados en ${group}`);
  }
}

function validateGraph(entriesById, prerequisiteLabel) {
  const visiting = new Set();
  const visited = new Set();
  const visit = (id, trail) => {
    if (visited.has(id)) return;
    if (visiting.has(id)) {
      report(errors, prerequisiteLabel, `ciclo detectado: ${[...trail, id].join(' -> ')}`);
      return;
    }
    visiting.add(id);
    for (const dependency of asArray(entriesById.get(id)?.data.prerequisites))
      visit(dependency, [...trail, id]);
    visiting.delete(id);
    visited.add(id);
  };
  for (const id of entriesById.keys()) visit(id, []);
}

function resolveWithin(base, untrustedPath) {
  if (!hasText(untrustedPath)) return undefined;
  const candidate = resolve(base, untrustedPath);
  const pathFromBase = relative(base, candidate);
  if (pathFromBase === '') return candidate;
  if (isAbsolute(pathFromBase) || pathFromBase === '..' || pathFromBase.startsWith(`..${sep}`))
    return undefined;
  return candidate;
}

async function validateLessonDetails(lessons, modulesById) {
  for (const lesson of lessons) {
    const { data, file } = lesson;
    const activities = asArray(data.activities);
    const seenKinds = new Set(activities.map((activity) => activity?.kind));
    const activityIds = activities.map((activity) => activity?.id).filter(hasText);
    const docRefLabels = new Set(asArray(data.docRefs).map((docRef) => docRef?.label));
    if (!lessonKinds.has(data.kind)) {
      report(errors, file, `«kind» debe ser concepto, taller o proyecto (recibido: ${data.kind})`);
    }
    if (activities.length < 4) report(errors, file, 'se requieren al menos cuatro actividades');
    if (activities.length > 8)
      report(errors, file, 'más de ocho actividades convierten la lección en un monolito');
    if (!uniqueValues(activityIds))
      report(errors, file, 'hay identificadores de actividad duplicados');
    for (const kind of requiredMovements[data.kind] ?? []) {
      if (!seenKinds.has(kind))
        report(
          errors,
          file,
          `una lección «${data.kind}» necesita el movimiento «${movementLabels[kind]}» (${kind})`,
        );
    }
    for (const activity of activities) {
      if (!activity || !hasText(activity.id) || !hasText(activity.prompt))
        report(errors, file, 'cada actividad necesita id y prompt');
      if (activity?.kind && !activityKinds.has(activity.kind))
        report(errors, file, `movimiento desconocido «${activity.kind}» en ${activity?.id}`);
      if (asArray(activity?.hints).length > 3)
        report(errors, file, `la actividad ${activity?.id ?? '(sin id)'} supera tres pistas`);
      if (hasText(activity?.sourceLabel)) {
        if (activity.kind !== 'source')
          report(errors, file, `sourceLabel solo aplica al movimiento Fuente (${activity.id})`);
        else if (!docRefLabels.has(activity.sourceLabel))
          report(
            errors,
            file,
            `${activity.id}: sourceLabel «${activity.sourceLabel}» no coincide con ningún docRefs`,
          );
      }
    }
    if (Number.isFinite(data.estimatedMinutes) && data.estimatedMinutes > sessionMinuteBudget) {
      report(
        errors,
        file,
        `estimatedMinutes ${data.estimatedMinutes} supera el presupuesto de ${sessionMinuteBudget} min; parte la lección`,
      );
    }
    if (asArray(data.reviewPrompts).length !== 4)
      report(errors, file, 'reviewPrompts debe contener exactamente cuatro preguntas');

    for (const docRef of asArray(data.docRefs)) {
      const label = hasText(docRef?.label) ? docRef.label : '(sin etiqueta)';
      try {
        const url = new URL(docRef?.url);
        if (url.protocol !== 'https:')
          report(errors, file, `${label}: la documentación debe usar HTTPS`);
        if (!officialDocumentationHosts.has(url.hostname))
          report(errors, file, `${label}: ${url.hostname} no es una fuente oficial permitida`);
      } catch {
        report(errors, file, `${label}: URL de documentación inválida`);
      }
      if (!/^\d{4}-\d{2}-\d{2}$/.test(docRef?.lastVerified ?? ''))
        report(errors, file, `${label}: lastVerified debe usar YYYY-MM-DD`);
    }

    if (!data.lab) {
      if (lessonKindsThatNeedLab.has(data.kind))
        report(errors, file, `una lección «${data.kind}» necesita declarar «lab»`);
      continue;
    }
    if (!['dart_lab', 'flutter_lab'].includes(data.lab.workspace)) {
      report(errors, file, `workspace de laboratorio no permitido: ${data.lab.workspace}`);
      continue;
    }
    const commandContract =
      data.lab.workspace === 'dart_lab'
        ? {
            test: /^fvm dart (?:run|test)(?:\s|$)/,
            analyze: /^fvm dart analyze(?:\s|$)/,
            description: 'fvm dart',
          }
        : {
            test: /^fvm flutter test(?:\s|$)/,
            analyze: /^fvm flutter analyze(?:\s|$)/,
            description: 'fvm flutter',
          };
    for (const [field, pattern] of [
      ['testCommand', commandContract.test],
      ['analyzeCommand', commandContract.analyze],
    ]) {
      const command = data.lab[field];
      if (!hasText(command) || !pattern.test(command)) {
        report(
          errors,
          file,
          `${field} debe usar ${commandContract.description} y ser compatible con ${data.lab.workspace}`,
        );
      } else if (unsafeCommandCharacters.test(command)) {
        report(errors, file, `${field} contiene operadores de shell no permitidos`);
      }
    }
    const workspace = join(repositoryDirectory, data.lab.workspace);
    const target = resolveWithin(workspace, data.lab.targetPath);
    if (!target) {
      report(errors, file, 'targetPath sale del workspace del laboratorio');
      continue;
    }
    const moduleStatus = modulesById.get(data.moduleId)?.data.status;
    try {
      await access(target);
    } catch {
      const message = `targetPath no existe: ${relative(repositoryDirectory, target)}`;
      if (moduleStatus === 'available') report(errors, file, message);
      else
        report(
          warnings,
          file,
          `${message} (permitido mientras el módulo sea ${moduleStatus ?? 'desconocido'})`,
        );
    }
  }
}

async function main() {
  const [tracks, modules, lessons] = await Promise.all([
    readJsonCollection('tracks'),
    readJsonCollection('modules'),
    readLessons(),
  ]);

  validateRequiredFields(tracks, ['id', 'slug', 'title', 'summary', 'promise', 'status']);
  validateRequiredFields(modules, ['id', 'trackId', 'slug', 'title', 'summary', 'status']);
  validateRequiredFields(lessons, ['id', 'trackId', 'moduleId', 'slug', 'title', 'summary']);
  validateUnique(tracks, (entry) => entry.data.id, 'id de ruta');
  validateUnique(tracks, (entry) => entry.data.slug, 'slug de ruta');
  validateUnique(modules, (entry) => entry.data.id, 'id de módulo');
  validateUnique(modules, (entry) => entry.data.slug, 'slug de módulo');
  validateUnique(lessons, (entry) => entry.data.id, 'id de lección');
  validateUnique(lessons, (entry) => entry.data.slug, 'slug de lección');
  validateOrder(tracks, () => 'tracks', 'tracks');
  validateOrder(modules, (entry) => entry.data.trackId, 'modules');
  validateOrder(lessons, (entry) => entry.data.moduleId, 'lessons');

  const tracksById = new Map(tracks.map((entry) => [entry.data.id, entry]));
  const modulesById = new Map(modules.map((entry) => [entry.data.id, entry]));
  const lessonsById = new Map(lessons.map((entry) => [entry.data.id, entry]));
  const moduleMembership = new Map();
  const lessonMembership = new Map();

  for (const track of tracks) {
    if (track.filename.replace(/\.json$/, '') !== track.data.id)
      report(errors, track.file, 'el nombre del archivo debe coincidir con id');
    const moduleIds = asArray(track.data.moduleIds);
    if (!uniqueValues(moduleIds)) report(errors, track.file, 'moduleIds contiene duplicados');
    for (const moduleId of moduleIds) {
      const module = modulesById.get(moduleId);
      if (!module) report(errors, track.file, `referencia un módulo inexistente: ${moduleId}`);
      else if (module.data.trackId !== track.data.id)
        report(errors, track.file, `${moduleId} declara trackId ${module.data.trackId}`);
      moduleMembership.set(moduleId, (moduleMembership.get(moduleId) ?? 0) + 1);
    }
  }

  for (const module of modules) {
    const { data, file } = module;
    if (!moduleIdPattern.test(data.id ?? ''))
      report(errors, file, 'id de módulo fuera del contrato D00–D15/F00–F06');
    if (module.filename.replace(/\.json$/, '') !== data.id)
      report(errors, file, 'el nombre del archivo debe coincidir con id');
    if (!tracksById.has(data.trackId)) report(errors, file, `trackId inexistente: ${data.trackId}`);
    if (moduleMembership.get(data.id) !== 1)
      report(
        errors,
        file,
        `debe aparecer exactamente una vez en moduleIds (aparece ${moduleMembership.get(data.id) ?? 0})`,
      );

    const prerequisites = asArray(data.prerequisites);
    if (!uniqueValues(prerequisites)) report(errors, file, 'prerequisites contiene duplicados');
    for (const prerequisiteId of prerequisites) {
      const prerequisite = modulesById.get(prerequisiteId);
      if (!prerequisite) report(errors, file, `prerrequisito inexistente: ${prerequisiteId}`);
      else if (prerequisiteId === data.id)
        report(errors, file, 'un módulo no puede depender de sí mismo');
      else if (prerequisite.data.trackId === data.trackId && prerequisite.data.order >= data.order)
        report(errors, file, `${prerequisiteId} debe aparecer antes que ${data.id}`);
    }

    const lessonIds = asArray(data.lessonIds);
    if (!uniqueValues(lessonIds)) report(errors, file, 'lessonIds contiene duplicados');
    if (data.status === 'available' && lessonIds.length === 0)
      report(errors, file, 'un módulo disponible necesita al menos una lección');
    if (data.status === 'available' && data.estimatedHours > 2 && lessonIds.length < 2) {
      report(
        errors,
        file,
        `${data.estimatedHours} h en una sola lección; parte el módulo en unidades de una sesión`,
      );
    }
    const declaredMinutes = lessonIds
      .map((lessonId) => lessonsById.get(lessonId)?.data.estimatedMinutes)
      .filter(Number.isFinite)
      .reduce((total, minutes) => total + minutes, 0);
    const budgetedMinutes = data.estimatedHours * 60;
    if (
      declaredMinutes > 0 &&
      Math.abs(declaredMinutes - budgetedMinutes) > budgetedMinutes * 0.25
    ) {
      report(
        warnings,
        file,
        `sus lecciones suman ${declaredMinutes} min y el módulo declara ${budgetedMinutes} min`,
      );
    }
    for (const lessonId of lessonIds) {
      const lesson = lessonsById.get(lessonId);
      if (!lesson) report(errors, file, `referencia una lección inexistente: ${lessonId}`);
      else if (lesson.data.moduleId !== data.id || lesson.data.trackId !== data.trackId)
        report(errors, file, `${lessonId} no coincide con el módulo/ruta que la contiene`);
      lessonMembership.set(lessonId, (lessonMembership.get(lessonId) ?? 0) + 1);
    }
  }

  for (const lesson of lessons) {
    const { data, file } = lesson;
    if (!lessonIdPattern.test(data.id ?? ''))
      report(errors, file, 'id de lección fuera del contrato');
    if (!modulesById.has(data.moduleId))
      report(errors, file, `moduleId inexistente: ${data.moduleId}`);
    if (lessonMembership.get(data.id) !== 1)
      report(
        errors,
        file,
        `debe aparecer exactamente una vez en lessonIds (aparece ${lessonMembership.get(data.id) ?? 0})`,
      );
    const prerequisites = asArray(data.prerequisites);
    if (!uniqueValues(prerequisites)) report(errors, file, 'prerequisites contiene duplicados');
    for (const prerequisiteId of prerequisites) {
      if (!lessonsById.has(prerequisiteId))
        report(errors, file, `prerrequisito de lección inexistente: ${prerequisiteId}`);
      if (prerequisiteId === data.id)
        report(errors, file, 'una lección no puede depender de sí misma');
    }
  }

  validateGraph(modulesById, 'module prerequisites');
  validateGraph(lessonsById, 'lesson prerequisites');
  await validateLessonDetails(lessons, modulesById);

  for (const warning of warnings) console.warn(`ADVERTENCIA ${warning}`);
  if (errors.length > 0) {
    for (const error of errors) console.error(`ERROR ${error}`);
    console.error(
      `\nContenido inválido: ${errors.length} error(es), ${warnings.length} advertencia(s).`,
    );
    process.exitCode = 1;
    return;
  }
  const pendingSplit = modules.filter(
    (module) => Number(module.data.estimatedHours) > 2 && asArray(module.data.lessonIds).length < 2,
  );
  console.log(
    `Contenido válido: ${tracks.length} rutas, ${modules.length} módulos y ${lessons.length} lecciones (${warnings.length} advertencia(s)).`,
  );
  if (pendingSplit.length > 0) {
    console.log(
      `Pendientes de partir en lecciones de una sesión: ${pendingSplit
        .map((module) => module.data.id)
        .join(', ')}.`,
    );
  }
}

await main();
