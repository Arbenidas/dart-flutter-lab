import {
  MAX_IDENTIFIER_LENGTH,
  MAX_IMPORT_BYTES,
  MAX_NOTE_LENGTH,
  MAX_RESPONSE_LENGTH,
  PROGRESS_FORMAT,
  PROGRESS_SCHEMA_VERSION,
  type AppMetaRecord,
  type ImportPreview,
  type LearnerSnapshot,
  type LessonProgressRecord,
  type ProgressExportV1,
  type ReviewProgress,
} from './types';

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}

function assertString(value: unknown, field: string, maxLength = Number.POSITIVE_INFINITY): string {
  if (typeof value !== 'string' || value.length > maxLength) {
    throw new TypeError(`El campo ${field} no tiene un formato válido.`);
  }
  return value;
}

function assertNonEmptyString(value: unknown, field: string, maxLength: number): string {
  const result = assertString(value, field, maxLength);
  if (result.trim().length === 0) {
    throw new TypeError(`El campo ${field} no puede estar vacío.`);
  }
  return result;
}

function assertIdentifier(value: unknown, field: string): string {
  return assertNonEmptyString(value, field, MAX_IDENTIFIER_LENGTH);
}

function assertUtcTimestamp(value: unknown, field: string): string {
  const result = assertString(value, field, 40);
  const timestamp = Date.parse(result);
  if (!Number.isFinite(timestamp) || new Date(timestamp).toISOString() !== result) {
    throw new TypeError(`El campo ${field} no contiene una fecha UTC válida.`);
  }
  return result;
}

function validateStringList(value: unknown, field: string): string[] {
  if (!Array.isArray(value)) {
    throw new TypeError(`El campo ${field} no es una lista válida.`);
  }
  const result = value.map((item, index) => assertIdentifier(item, `${field}[${index}]`));
  if (new Set(result).size !== result.length) {
    throw new TypeError(`El campo ${field} contiene identificadores duplicados.`);
  }
  return result;
}

function validateResponses(value: unknown): Record<string, string> {
  if (!isRecord(value)) {
    throw new TypeError('Las respuestas importadas no son válidas.');
  }
  return Object.fromEntries(
    Object.entries(value).map(([key, response]) => [
      assertIdentifier(key, 'responsesByActivityId.<id>'),
      assertString(response, `responsesByActivityId.${key}`, MAX_RESPONSE_LENGTH),
    ]),
  );
}

function validateReview(value: unknown): ReviewProgress | undefined {
  if (value === undefined) return undefined;
  if (!isRecord(value) || typeof value.stage !== 'number' || ![0, 1, 2, 3].includes(value.stage)) {
    throw new TypeError('El repaso importado no es válido.');
  }

  const dueAtUtc =
    value.dueAtUtc === undefined
      ? undefined
      : assertUtcTimestamp(value.dueAtUtc, 'review.dueAtUtc');
  const lastReviewedAtUtc =
    value.lastReviewedAtUtc === undefined
      ? undefined
      : assertUtcTimestamp(value.lastReviewedAtUtc, 'review.lastReviewedAtUtc');

  return {
    stage: value.stage as ReviewProgress['stage'],
    ...(dueAtUtc === undefined ? {} : { dueAtUtc }),
    ...(lastReviewedAtUtc === undefined ? {} : { lastReviewedAtUtc }),
  };
}

function validateLesson(value: unknown): LessonProgressRecord {
  if (!isRecord(value)) {
    throw new TypeError('Una lección importada no tiene formato válido.');
  }

  const completedAtUtc =
    value.completedAtUtc === undefined
      ? undefined
      : assertUtcTimestamp(value.completedAtUtc, 'completedAtUtc');
  const retainedAtUtc =
    value.retainedAtUtc === undefined
      ? undefined
      : assertUtcTimestamp(value.retainedAtUtc, 'retainedAtUtc');
  const noteUpdatedAtUtc =
    value.noteUpdatedAtUtc === undefined
      ? undefined
      : assertUtcTimestamp(value.noteUpdatedAtUtc, 'noteUpdatedAtUtc');
  const review = validateReview(value.review);
  const attemptCount = value.attemptCount ?? 0;

  if (typeof attemptCount !== 'number' || !Number.isSafeInteger(attemptCount) || attemptCount < 0) {
    throw new TypeError('La cantidad de intentos importada no es válida.');
  }

  if (review && !completedAtUtc) {
    throw new TypeError('Un repaso importado necesita una lección completada.');
  }
  if (completedAtUtc && !review) {
    throw new TypeError('Una lección completada necesita una agenda de repaso.');
  }
  if (retainedAtUtc && (!completedAtUtc || review?.stage !== 3 || review.dueAtUtc)) {
    throw new TypeError('El estado de retención importado no es coherente.');
  }
  if (review && !retainedAtUtc && !review.dueAtUtc) {
    throw new TypeError('Un repaso pendiente necesita una fecha programada.');
  }

  return {
    lessonId: assertIdentifier(value.lessonId, 'lessonId'),
    startedAtUtc: assertUtcTimestamp(value.startedAtUtc, 'startedAtUtc'),
    lastOpenedAtUtc: assertUtcTimestamp(value.lastOpenedAtUtc, 'lastOpenedAtUtc'),
    ...(completedAtUtc === undefined ? {} : { completedAtUtc }),
    ...(retainedAtUtc === undefined ? {} : { retainedAtUtc }),
    attemptCount,
    completedActivityIds: validateStringList(value.completedActivityIds, 'completedActivityIds'),
    responsesByActivityId: validateResponses(value.responsesByActivityId),
    revealedHintIds: validateStringList(value.revealedHintIds, 'revealedHintIds'),
    note: assertString(value.note, 'note', MAX_NOTE_LENGTH),
    ...(noteUpdatedAtUtc === undefined ? {} : { noteUpdatedAtUtc }),
    ...(review === undefined ? {} : { review }),
    updatedAtUtc: assertUtcTimestamp(value.updatedAtUtc, 'updatedAtUtc'),
  };
}

export function createProgressExport(
  snapshot: LearnerSnapshot,
  appVersion: string,
  contentVersion: string,
  exportedAt = new Date(),
): ProgressExportV1 {
  const copy = structuredClone(snapshot);
  return {
    format: PROGRESS_FORMAT,
    schemaVersion: PROGRESS_SCHEMA_VERSION,
    exportedAtUtc: exportedAt.toISOString(),
    appVersion,
    contentVersion,
    meta: copy.meta,
    lessons: copy.lessons,
  };
}

export function parseProgressImport(text: string): ImportPreview {
  if (new TextEncoder().encode(text).byteLength > MAX_IMPORT_BYTES) {
    throw new RangeError('El archivo supera el límite de 2 MB.');
  }
  let value: unknown;
  try {
    value = JSON.parse(text) as unknown;
  } catch {
    throw new SyntaxError('El archivo no contiene JSON válido.');
  }
  if (!isRecord(value) || value.format !== PROGRESS_FORMAT) {
    throw new TypeError('El archivo no pertenece a Dart & Flutter Lab.');
  }
  if (value.schemaVersion !== PROGRESS_SCHEMA_VERSION) {
    throw new TypeError('Esta versión del archivo todavía no es compatible.');
  }
  if (!isRecord(value.meta) || !Array.isArray(value.lessons)) {
    throw new TypeError('El archivo no contiene un estado válido.');
  }

  const meta = value.meta;
  if (meta.key !== 'state' || meta.schemaVersion !== PROGRESS_SCHEMA_VERSION) {
    throw new TypeError('Los metadatos importados no son compatibles.');
  }
  if (
    typeof meta.revision !== 'number' ||
    !Number.isSafeInteger(meta.revision) ||
    meta.revision < 0
  ) {
    throw new TypeError('La revisión importada no es válida.');
  }

  const lessons = value.lessons.map(validateLesson);
  const lessonIds = new Set(lessons.map((lesson) => lesson.lessonId));
  if (lessonIds.size !== lessons.length) {
    throw new TypeError('El archivo contiene lecciones duplicadas.');
  }

  const lastLessonId =
    meta.lastLessonId === undefined
      ? undefined
      : assertIdentifier(meta.lastLessonId, 'lastLessonId');
  if (lastLessonId !== undefined && !lessonIds.has(lastLessonId)) {
    throw new TypeError('La última lección importada no existe en el estado.');
  }

  const validatedMeta: AppMetaRecord = {
    key: 'state',
    schemaVersion: PROGRESS_SCHEMA_VERSION,
    contentVersionSeen: assertNonEmptyString(meta.contentVersionSeen, 'contentVersionSeen', 80),
    revision: meta.revision,
    updatedAtUtc: assertUtcTimestamp(meta.updatedAtUtc, 'updatedAtUtc'),
    ...(lastLessonId === undefined ? {} : { lastLessonId }),
  };
  const data: ProgressExportV1 = {
    format: PROGRESS_FORMAT,
    schemaVersion: PROGRESS_SCHEMA_VERSION,
    exportedAtUtc: assertUtcTimestamp(value.exportedAtUtc, 'exportedAtUtc'),
    appVersion: assertNonEmptyString(value.appVersion, 'appVersion', 80),
    contentVersion: assertNonEmptyString(value.contentVersion, 'contentVersion', 80),
    meta: validatedMeta,
    lessons,
  };

  return {
    lessonCount: lessons.length,
    noteCount: lessons.filter((lesson) => lesson.note.trim().length > 0).length,
    completedCount: lessons.filter((lesson) => lesson.completedAtUtc).length,
    retainedCount: lessons.filter((lesson) => lesson.retainedAtUtc).length,
    exportedAtUtc: data.exportedAtUtc,
    contentVersion: data.contentVersion,
    data,
  };
}

export function exportFilename(date = new Date()): string {
  return `flutter-lab-progreso-${date.toISOString().slice(0, 10)}.json`;
}
