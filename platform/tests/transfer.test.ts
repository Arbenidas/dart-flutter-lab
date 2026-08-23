import { describe, expect, it } from 'vitest';

import {
  createProgressExport,
  exportFilename,
  MAX_IMPORT_BYTES,
  MAX_NOTE_LENGTH,
  parseProgressImport,
  PROGRESS_SCHEMA_VERSION,
  snapshotFromExport,
} from '../src/lib/progress';
import type { LearnerSnapshot, LessonProgressRecord, ProgressExportV1 } from '../src/lib/progress';

const at = '2026-01-01T00:00:00.000Z';

function lesson(): LessonProgressRecord {
  return {
    lessonId: 'd01-tipos',
    startedAtUtc: at,
    lastOpenedAtUtc: at,
    completedAtUtc: at,
    attemptCount: 2,
    completedActivityIds: ['predict'],
    responsesByActivityId: { predict: 'Un entero.' },
    revealedHintIds: ['tipos-hint'],
    note: 'Recordar la diferencia entre final y const.',
    review: { stage: 0, dueAtUtc: '2026-01-02T00:00:00.000Z' },
    updatedAtUtc: at,
  };
}

function snapshot(): LearnerSnapshot {
  return {
    meta: {
      key: 'state',
      schemaVersion: PROGRESS_SCHEMA_VERSION,
      contentVersionSeen: 'v1',
      revision: 2,
      updatedAtUtc: at,
      lastLessonId: 'd01-tipos',
    },
    lessons: [lesson()],
  };
}

function progressExport(): ProgressExportV1 {
  return createProgressExport(snapshot(), '0.1.0', 'v1', new Date('2026-01-02T00:00:00Z'));
}

type MutableExport = Omit<ProgressExportV1, 'meta' | 'lessons'> & {
  meta: Record<string, unknown>;
  lessons: Array<Record<string, unknown>>;
};

function mutableExport(): MutableExport {
  return structuredClone(progressExport()) as unknown as MutableExport;
}

describe('portabilidad del progreso', () => {
  it('exporta y valida el mismo estado', () => {
    const source = snapshot();
    const exported = createProgressExport(source, '0.1.0', 'v1', new Date('2026-01-02T00:00:00Z'));
    source.lessons[0]!.note = 'mutada después de exportar';
    const preview = parseProgressImport(JSON.stringify(exported));
    expect(preview.data.meta).toEqual(snapshot().meta);
    expect(preview.data.lessons[0]?.note).toBe('Recordar la diferencia entre final y const.');
    expect(preview.data.lessons[0]?.attemptCount).toBe(2);
    expect(preview).toMatchObject({
      lessonCount: 1,
      noteCount: 1,
      completedCount: 1,
      retainedCount: 0,
    });
  });

  it('rechaza JSON ajeno sin producir una vista previa', () => {
    expect(() => parseProgressImport('{"format":"otro"}')).toThrow(
      'El archivo no pertenece a Dart & Flutter Lab.',
    );
  });

  it('rechaza JSON roto, esquema ajeno y archivos mayores a 2 MB', () => {
    expect(() => parseProgressImport('{')).toThrow('El archivo no contiene JSON válido.');
    const wrongSchema = mutableExport();
    wrongSchema.schemaVersion = 99 as typeof PROGRESS_SCHEMA_VERSION;
    expect(() => parseProgressImport(JSON.stringify(wrongSchema))).toThrow(
      'Esta versión del archivo todavía no es compatible.',
    );
    expect(() => parseProgressImport('x'.repeat(MAX_IMPORT_BYTES + 1))).toThrow(
      'El archivo supera el límite de 2 MB.',
    );
  });

  it('rechaza fechas, revisiones y etapas que solo parecen válidas', () => {
    const invalidDate = mutableExport();
    invalidDate.meta.updatedAtUtc = 'ayer';
    expect(() => parseProgressImport(JSON.stringify(invalidDate))).toThrow('fecha UTC válida');

    const stringRevision = mutableExport();
    stringRevision.meta.revision = '2';
    expect(() => parseProgressImport(JSON.stringify(stringRevision))).toThrow(
      'La revisión importada no es válida.',
    );

    const stringStage = mutableExport();
    stringStage.lessons[0]!.review = {
      stage: '0',
      dueAtUtc: '2026-01-02T00:00:00.000Z',
    };
    expect(() => parseProgressImport(JSON.stringify(stringStage))).toThrow(
      'El repaso importado no es válido.',
    );

    const negativeAttempts = mutableExport();
    negativeAttempts.lessons[0]!.attemptCount = -1;
    expect(() => parseProgressImport(JSON.stringify(negativeAttempts))).toThrow(
      'La cantidad de intentos importada no es válida.',
    );
  });

  it('migra exportaciones v1 anteriores al contador con cero intentos', () => {
    const legacy = mutableExport();
    delete legacy.lessons[0]!.attemptCount;
    const parsed = parseProgressImport(JSON.stringify(legacy));
    expect(parsed.data.lessons[0]?.attemptCount).toBe(0);
  });

  it('rechaza lecciones e identificadores duplicados', () => {
    const duplicateLesson = mutableExport();
    duplicateLesson.lessons.push(structuredClone(duplicateLesson.lessons[0]!));
    expect(() => parseProgressImport(JSON.stringify(duplicateLesson))).toThrow(
      'El archivo contiene lecciones duplicadas.',
    );

    const duplicateActivity = mutableExport();
    duplicateActivity.lessons[0]!.completedActivityIds = ['predict', 'predict'];
    expect(() => parseProgressImport(JSON.stringify(duplicateActivity))).toThrow(
      'contiene identificadores duplicados',
    );
  });

  it('rechaza estados de repaso y retención incoherentes', () => {
    const reviewWithoutCompletion = mutableExport();
    delete reviewWithoutCompletion.lessons[0]!.completedAtUtc;
    expect(() => parseProgressImport(JSON.stringify(reviewWithoutCompletion))).toThrow(
      'Un repaso importado necesita una lección completada.',
    );

    const retainedWithPendingDueDate = mutableExport();
    retainedWithPendingDueDate.lessons[0]!.retainedAtUtc = '2026-02-02T00:00:00.000Z';
    retainedWithPendingDueDate.lessons[0]!.review = {
      stage: 3,
      dueAtUtc: '2026-02-02T00:00:00.000Z',
    };
    expect(() => parseProgressImport(JSON.stringify(retainedWithPendingDueDate))).toThrow(
      'El estado de retención importado no es coherente.',
    );
  });

  it('rechaza referencias inexistentes y notas demasiado largas', () => {
    const missingLastLesson = mutableExport();
    missingLastLesson.meta.lastLessonId = 'no-existe';
    expect(() => parseProgressImport(JSON.stringify(missingLastLesson))).toThrow(
      'La última lección importada no existe en el estado.',
    );

    const longNote = mutableExport();
    longNote.lessons[0]!.note = 'x'.repeat(MAX_NOTE_LENGTH + 1);
    expect(() => parseProgressImport(JSON.stringify(longNote))).toThrow(
      'El campo note no tiene un formato válido.',
    );
  });

  it('desacopla el snapshot restaurado del objeto exportado', () => {
    const exported = progressExport();
    const restored = snapshotFromExport(exported);
    restored.lessons[0]!.note = 'cambio local';
    expect(exported.lessons[0]?.note).toBe('Recordar la diferencia entre final y const.');
  });

  it('genera un nombre estable con la fecha UTC', () => {
    expect(exportFilename(new Date('2026-08-23T23:59:00-06:00'))).toBe(
      'flutter-lab-progreso-2026-08-24.json',
    );
  });
});
