import { afterEach, describe, expect, it, vi } from 'vitest';

import { createDatabase, type LabDatabase } from '../src/lib/progress/db';
import {
  createProgressRepository,
  IndexedDbProgressRepository,
  MemoryProgressRepository,
  PROGRESS_SCHEMA_VERSION,
} from '../src/lib/progress';
import type { LearnerSnapshot, LessonProgressRecord } from '../src/lib/progress';

let databaseSequence = 0;
const databases: LabDatabase[] = [];

function database(): LabDatabase {
  databaseSequence += 1;
  const result = createDatabase(`progress-test-${databaseSequence}`);
  databases.push(result);
  return result;
}

function lesson(lessonId = 'D01-L01'): LessonProgressRecord {
  return {
    lessonId,
    startedAtUtc: '2026-01-01T00:00:00.000Z',
    lastOpenedAtUtc: '2026-01-01T00:00:00.000Z',
    attemptCount: 3,
    completedActivityIds: ['predict'],
    responsesByActivityId: {},
    revealedHintIds: [],
    note: 'Importada',
    updatedAtUtc: '2026-01-01T00:00:00.000Z',
  };
}

function importedSnapshot(revision = 10): LearnerSnapshot {
  return {
    meta: {
      key: 'state',
      schemaVersion: PROGRESS_SCHEMA_VERSION,
      contentVersionSeen: 'old-content',
      revision,
      updatedAtUtc: '2026-01-01T00:00:00.000Z',
      lastLessonId: 'D01-L01',
    },
    lessons: [lesson()],
  };
}

afterEach(async () => {
  vi.useRealTimers();
  await Promise.all(databases.splice(0).map((item) => item.delete()));
});

describe('repositorio en memoria', () => {
  it('persiste marcar y desmarcar, y cuenta confirmaciones explícitas', async () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date('2026-01-01T12:00:00.000Z'));
    const repository = new MemoryProgressRepository('content-v1');

    await repository.markOpened('D01-L01');
    await repository.completeActivity('D01-L01', 'predict');
    await repository.completeActivity('D01-L01', 'predict');
    await repository.setActivityCompletion('D01-L01', 'predict', false);
    await repository.confirmLesson('D01-L01');
    await repository.confirmLesson('D01-L01');

    const snapshot = await repository.getSnapshot();
    expect(snapshot.lessons[0]).toMatchObject({
      attemptCount: 2,
      completedActivityIds: [],
      completedAtUtc: '2026-01-01T12:00:00.000Z',
      updatedAtUtc: '2026-01-01T12:00:00.000Z',
      review: { stage: 0, dueAtUtc: '2026-01-02T12:00:00.000Z' },
    });
    expect(snapshot.meta).toMatchObject({
      revision: 6,
      updatedAtUtc: '2026-01-01T12:00:00.000Z',
      lastLessonId: 'D01-L01',
    });
  });

  it('no crea progreso al intentar repasar antes de completar', async () => {
    const repository = new MemoryProgressRepository('content-v1');
    await expect(repository.recordReview('D01-L01', true)).rejects.toThrow(
      'No se puede registrar un repaso antes de completar la lección.',
    );
    expect(await repository.getSnapshot()).toMatchObject({
      meta: { revision: 0 },
      lessons: [],
    });
  });

  it('reemplaza sin alias, conserva revisión monótona y limpia el último id', async () => {
    const repository = new MemoryProgressRepository('current-content');
    const imported = importedSnapshot();
    await repository.replace(imported);
    imported.lessons[0]!.note = 'mutación externa';

    const replaced = await repository.getSnapshot();
    expect(replaced.meta).toMatchObject({
      revision: 11,
      contentVersionSeen: 'current-content',
      lastLessonId: 'D01-L01',
    });
    expect(replaced.lessons[0]?.note).toBe('Importada');

    await repository.clear();
    const cleared = await repository.getSnapshot();
    expect(cleared.meta.revision).toBe(12);
    expect(cleared.meta).not.toHaveProperty('lastLessonId');
    expect(cleared.lessons).toEqual([]);
  });

  it('rechaza ids vacíos sin alterar el estado', async () => {
    const repository = new MemoryProgressRepository('content-v1');
    await expect(repository.markOpened('   ')).rejects.toThrow('lessonId');
    await expect(repository.completeActivity('D01-L01', '')).rejects.toThrow('activityId');
    expect((await repository.getSnapshot()).lessons).toEqual([]);
  });
});

describe('repositorio IndexedDB', () => {
  it('persiste intentos y el estado desmarcado al volver a abrir', async () => {
    const name = `progress-persist-${databaseSequence + 1}`;
    const firstDatabase = createDatabase(name);
    databases.push(firstDatabase);
    const first = new IndexedDbProgressRepository('content-v1', firstDatabase);
    await first.open();
    await first.completeActivity('D01-L01', 'predict');
    await first.setActivityCompletion('D01-L01', 'predict', false);
    await first.confirmLesson('D01-L01');

    firstDatabase.close();
    const secondDatabase = createDatabase(name);
    databases.push(secondDatabase);
    const second = new IndexedDbProgressRepository('content-v1', secondDatabase);
    await second.open();
    const restored = await second.getSnapshot();

    expect(restored.lessons[0]).toMatchObject({
      attemptCount: 1,
      completedActivityIds: [],
    });
  });

  it('revierte clear y meta si bulkPut falla durante una importación', async () => {
    const db = database();
    const repository = new IndexedDbProgressRepository('content-v1', db);
    await repository.open();
    await repository.setNote('D01-L01', 'estado anterior');
    const before = await repository.getSnapshot();

    const invalidLesson = lesson() as Partial<LessonProgressRecord>;
    delete invalidLesson.lessonId;
    const invalid = importedSnapshot(50);
    invalid.lessons = [invalidLesson as LessonProgressRecord];

    await expect(repository.replace(invalid)).rejects.toThrow();
    expect(await repository.getSnapshot()).toEqual(before);
  });

  it('comparte un único fallback en memoria y cierra la base fallida', async () => {
    const db = database();
    const open = vi.spyOn(db, 'open').mockRejectedValueOnce(new Error('IndexedDB bloqueado'));
    const close = vi.spyOn(db, 'close');
    const factory = vi.fn(() => db);
    const contentVersion = `fallback-${databaseSequence}`;

    const [first, second] = await Promise.all([
      createProgressRepository(contentVersion, factory),
      createProgressRepository(contentVersion, factory),
    ]);
    await first.setNote('D01-L01', 'sobrevive entre consumidores');
    const third = await createProgressRepository(contentVersion, factory);

    expect(first.mode).toBe('memory');
    expect(second).toBe(first);
    expect(third).toBe(first);
    expect(factory).toHaveBeenCalledTimes(1);
    expect(open).toHaveBeenCalledTimes(1);
    expect(close).toHaveBeenCalledTimes(1);
    expect((await second.getSnapshot()).lessons[0]?.note).toBe('sobrevive entre consumidores');
  });
});
