import { liveQuery, type Subscription } from 'dexie';

import { createDatabase, type LabDatabase } from './db';
import { advanceReview, scheduleFirstReview } from './schedule';
import {
  MAX_IDENTIFIER_LENGTH,
  MAX_NOTE_LENGTH,
  MAX_RESPONSE_LENGTH,
  PROGRESS_SCHEMA_VERSION,
  type AppMetaRecord,
  type LearnerSnapshot,
  type LessonProgressRecord,
  type ProgressExportV1,
} from './types';

export interface ProgressRepository {
  readonly mode: 'indexeddb' | 'memory';
  getSnapshot(): Promise<LearnerSnapshot>;
  markOpened(lessonId: string): Promise<LessonProgressRecord>;
  setNote(lessonId: string, note: string): Promise<void>;
  setResponse(lessonId: string, activityId: string, response: string): Promise<void>;
  revealHint(lessonId: string, hintId: string): Promise<void>;
  setActivityCompletion(lessonId: string, activityId: string, completed: boolean): Promise<void>;
  completeActivity(lessonId: string, activityId: string): Promise<void>;
  confirmLesson(lessonId: string): Promise<void>;
  recordReview(lessonId: string, recalledWithoutHelp: boolean): Promise<void>;
  replace(snapshot: LearnerSnapshot): Promise<void>;
  clear(): Promise<void>;
  subscribe(listener: (snapshot: LearnerSnapshot) => void): () => void;
}

function nowUtc(): string {
  return new Date().toISOString();
}

function makeMeta(contentVersion: string): AppMetaRecord {
  return {
    key: 'state',
    schemaVersion: PROGRESS_SCHEMA_VERSION,
    contentVersionSeen: contentVersion,
    revision: 0,
    updatedAtUtc: nowUtc(),
  };
}

function makeProgress(lessonId: string, at = nowUtc()): LessonProgressRecord {
  return {
    lessonId,
    startedAtUtc: at,
    lastOpenedAtUtc: at,
    attemptCount: 0,
    completedActivityIds: [],
    responsesByActivityId: {},
    revealedHintIds: [],
    note: '',
    updatedAtUtc: at,
  };
}

function unique(values: string[]): string[] {
  return [...new Set(values)];
}

function assertIdentifier(value: string, field: string): void {
  if (value.trim().length === 0 || value.length > MAX_IDENTIFIER_LENGTH) {
    throw new TypeError(`El identificador ${field} no es válido.`);
  }
}

function cloneSnapshot(snapshot: LearnerSnapshot): LearnerSnapshot {
  const copy = structuredClone(snapshot);
  copy.lessons = copy.lessons.map(normalizeProgress);
  copy.lessons.sort((left, right) => left.lessonId.localeCompare(right.lessonId));
  return copy;
}

function normalizeProgress(progress: LessonProgressRecord): LessonProgressRecord {
  const attemptCount = progress.attemptCount ?? 0;
  if (!Number.isSafeInteger(attemptCount) || attemptCount < 0) {
    throw new TypeError('La cantidad de intentos no es válida.');
  }
  return { ...progress, attemptCount };
}

function replacementMeta(
  current: AppMetaRecord | undefined,
  incoming: AppMetaRecord,
  lessons: LessonProgressRecord[],
  contentVersion: string,
  at: string,
): AppMetaRecord {
  const lastLessonId = incoming.lastLessonId;
  return {
    key: 'state',
    schemaVersion: PROGRESS_SCHEMA_VERSION,
    contentVersionSeen: contentVersion,
    revision: Math.max(current?.revision ?? 0, incoming.revision) + 1,
    updatedAtUtc: at,
    ...(lastLessonId && lessons.some((lesson) => lesson.lessonId === lastLessonId)
      ? { lastLessonId }
      : {}),
  };
}

export class IndexedDbProgressRepository implements ProgressRepository {
  readonly mode = 'indexeddb' as const;

  constructor(
    private readonly contentVersion: string,
    private readonly db: LabDatabase = createDatabase(),
  ) {}

  async open(): Promise<void> {
    await this.db.open();
    if (!(await this.db.meta.get('state'))) await this.db.meta.put(makeMeta(this.contentVersion));
  }

  async getSnapshot(): Promise<LearnerSnapshot> {
    const meta = (await this.db.meta.get('state')) ?? makeMeta(this.contentVersion);
    return cloneSnapshot({ meta, lessons: await this.db.lessonProgress.toArray() });
  }

  private async mutate(
    lessonId: string,
    update: (current: LessonProgressRecord, at: string) => LessonProgressRecord,
  ): Promise<LessonProgressRecord> {
    assertIdentifier(lessonId, 'lessonId');
    return this.db.transaction('rw', this.db.meta, this.db.lessonProgress, async () => {
      const at = nowUtc();
      const stored = await this.db.lessonProgress.get(lessonId);
      const current = stored ? normalizeProgress(stored) : makeProgress(lessonId, at);
      const next = { ...update(current, at), lessonId, updatedAtUtc: at };
      await this.db.lessonProgress.put(next);
      const meta = (await this.db.meta.get('state')) ?? makeMeta(this.contentVersion);
      await this.db.meta.put({
        ...meta,
        contentVersionSeen: this.contentVersion,
        revision: meta.revision + 1,
        updatedAtUtc: at,
        lastLessonId: lessonId,
      });
      return next;
    });
  }

  markOpened(lessonId: string): Promise<LessonProgressRecord> {
    return this.mutate(lessonId, (current, at) => ({
      ...current,
      lastOpenedAtUtc: at,
      updatedAtUtc: at,
    }));
  }

  async setNote(lessonId: string, note: string): Promise<void> {
    if (note.length > MAX_NOTE_LENGTH) throw new RangeError('La nota supera 10 000 caracteres.');
    await this.mutate(lessonId, (current, at) => ({
      ...current,
      note,
      noteUpdatedAtUtc: at,
      updatedAtUtc: at,
    }));
  }

  async setResponse(lessonId: string, activityId: string, response: string): Promise<void> {
    assertIdentifier(activityId, 'activityId');
    if (response.length > MAX_RESPONSE_LENGTH) {
      throw new RangeError('La respuesta supera 5 000 caracteres.');
    }
    await this.mutate(lessonId, (current, at) => ({
      ...current,
      responsesByActivityId: { ...current.responsesByActivityId, [activityId]: response },
      updatedAtUtc: at,
    }));
  }

  async revealHint(lessonId: string, hintId: string): Promise<void> {
    assertIdentifier(hintId, 'hintId');
    await this.mutate(lessonId, (current, at) => ({
      ...current,
      revealedHintIds: unique([...current.revealedHintIds, hintId]),
      updatedAtUtc: at,
    }));
  }

  async setActivityCompletion(
    lessonId: string,
    activityId: string,
    completed: boolean,
  ): Promise<void> {
    assertIdentifier(activityId, 'activityId');
    await this.mutate(lessonId, (current, at) => ({
      ...current,
      completedActivityIds: completed
        ? unique([...current.completedActivityIds, activityId])
        : current.completedActivityIds.filter((id) => id !== activityId),
      updatedAtUtc: at,
    }));
  }

  async completeActivity(lessonId: string, activityId: string): Promise<void> {
    await this.setActivityCompletion(lessonId, activityId, true);
  }

  async confirmLesson(lessonId: string): Promise<void> {
    await this.mutate(lessonId, (current, at) => {
      const completedAtUtc = current.completedAtUtc ?? at;
      return {
        ...current,
        attemptCount: current.attemptCount + 1,
        completedAtUtc,
        review: current.review ?? scheduleFirstReview(new Date(completedAtUtc)),
        updatedAtUtc: at,
      };
    });
  }

  async recordReview(lessonId: string, recalledWithoutHelp: boolean): Promise<void> {
    await this.mutate(lessonId, (current, at) =>
      advanceReview(current, recalledWithoutHelp, new Date(at)),
    );
  }

  async replace(snapshot: LearnerSnapshot): Promise<void> {
    const copy = cloneSnapshot(snapshot);
    await this.db.transaction('rw', this.db.meta, this.db.lessonProgress, async () => {
      const current = await this.db.meta.get('state');
      const at = nowUtc();
      await this.db.meta.clear();
      await this.db.lessonProgress.clear();
      await this.db.meta.put(
        replacementMeta(current, copy.meta, copy.lessons, this.contentVersion, at),
      );
      await this.db.lessonProgress.bulkPut(copy.lessons);
    });
  }

  async clear(): Promise<void> {
    await this.replace({ meta: makeMeta(this.contentVersion), lessons: [] });
  }

  subscribe(listener: (snapshot: LearnerSnapshot) => void): () => void {
    const subscription: Subscription = liveQuery(() => this.getSnapshot()).subscribe({
      next: listener,
      error: () => undefined,
    });
    return () => subscription.unsubscribe();
  }
}

export class MemoryProgressRepository implements ProgressRepository {
  readonly mode = 'memory' as const;
  private snapshot: LearnerSnapshot;
  private readonly listeners = new Set<(snapshot: LearnerSnapshot) => void>();

  constructor(
    private readonly contentVersion: string,
    initial?: LearnerSnapshot,
  ) {
    this.snapshot = initial
      ? cloneSnapshot(initial)
      : { meta: makeMeta(contentVersion), lessons: [] };
  }

  async getSnapshot(): Promise<LearnerSnapshot> {
    return cloneSnapshot(this.snapshot);
  }

  private update(
    lessonId: string,
    updater: (current: LessonProgressRecord, at: string) => LessonProgressRecord,
  ): LessonProgressRecord {
    assertIdentifier(lessonId, 'lessonId');
    const at = nowUtc();
    const current =
      this.snapshot.lessons.find((item) => item.lessonId === lessonId) ??
      makeProgress(lessonId, at);
    const next = { ...updater(current, at), lessonId, updatedAtUtc: at };
    this.snapshot.lessons = [
      ...this.snapshot.lessons.filter((item) => item.lessonId !== lessonId),
      next,
    ];
    this.snapshot.meta = {
      ...this.snapshot.meta,
      contentVersionSeen: this.contentVersion,
      revision: this.snapshot.meta.revision + 1,
      updatedAtUtc: at,
      lastLessonId: lessonId,
    };
    this.emit();
    return next;
  }

  async markOpened(lessonId: string): Promise<LessonProgressRecord> {
    return this.update(lessonId, (current, at) => ({
      ...current,
      lastOpenedAtUtc: at,
    }));
  }

  async setNote(lessonId: string, note: string): Promise<void> {
    if (note.length > MAX_NOTE_LENGTH) throw new RangeError('La nota supera 10 000 caracteres.');
    this.update(lessonId, (current, at) => ({ ...current, note, noteUpdatedAtUtc: at }));
  }

  async setResponse(lessonId: string, activityId: string, response: string): Promise<void> {
    assertIdentifier(activityId, 'activityId');
    if (response.length > MAX_RESPONSE_LENGTH)
      throw new RangeError('La respuesta supera 5 000 caracteres.');
    this.update(lessonId, (current) => ({
      ...current,
      responsesByActivityId: { ...current.responsesByActivityId, [activityId]: response },
    }));
  }

  async revealHint(lessonId: string, hintId: string): Promise<void> {
    assertIdentifier(hintId, 'hintId');
    this.update(lessonId, (current) => ({
      ...current,
      revealedHintIds: unique([...current.revealedHintIds, hintId]),
    }));
  }

  async setActivityCompletion(
    lessonId: string,
    activityId: string,
    completed: boolean,
  ): Promise<void> {
    assertIdentifier(activityId, 'activityId');
    this.update(lessonId, (current) => ({
      ...current,
      completedActivityIds: completed
        ? unique([...current.completedActivityIds, activityId])
        : current.completedActivityIds.filter((id) => id !== activityId),
    }));
  }

  async completeActivity(lessonId: string, activityId: string): Promise<void> {
    await this.setActivityCompletion(lessonId, activityId, true);
  }

  async confirmLesson(lessonId: string): Promise<void> {
    this.update(lessonId, (current, at) => {
      const completedAtUtc = current.completedAtUtc ?? at;
      return {
        ...current,
        attemptCount: current.attemptCount + 1,
        completedAtUtc,
        review: current.review ?? scheduleFirstReview(new Date(completedAtUtc)),
      };
    });
  }

  async recordReview(lessonId: string, recalledWithoutHelp: boolean): Promise<void> {
    this.update(lessonId, (current, at) =>
      advanceReview(current, recalledWithoutHelp, new Date(at)),
    );
  }

  async replace(snapshot: LearnerSnapshot): Promise<void> {
    const copy = cloneSnapshot(snapshot);
    const at = nowUtc();
    copy.meta = replacementMeta(
      this.snapshot.meta,
      copy.meta,
      copy.lessons,
      this.contentVersion,
      at,
    );
    this.snapshot = copy;
    this.emit();
  }

  async clear(): Promise<void> {
    await this.replace({ meta: makeMeta(this.contentVersion), lessons: [] });
  }

  subscribe(listener: (snapshot: LearnerSnapshot) => void): () => void {
    this.listeners.add(listener);
    return () => this.listeners.delete(listener);
  }

  private emit(): void {
    void this.getSnapshot().then((snapshot) =>
      this.listeners.forEach((listener) => listener(snapshot)),
    );
  }
}

const repositoryPromises = new Map<string, Promise<ProgressRepository>>();

async function initializeProgressRepository(
  contentVersion: string,
  databaseFactory: () => LabDatabase,
): Promise<ProgressRepository> {
  let database: LabDatabase | undefined;
  try {
    database = databaseFactory();
    const repository = new IndexedDbProgressRepository(contentVersion, database);
    await repository.open();
    return repository;
  } catch {
    try {
      database?.close();
    } catch {
      // El cierre es best effort; el fallback debe seguir disponible.
    }
    return new MemoryProgressRepository(contentVersion);
  }
}

export function createProgressRepository(
  contentVersion: string,
  databaseFactory: () => LabDatabase = createDatabase,
): Promise<ProgressRepository> {
  const existing = repositoryPromises.get(contentVersion);
  if (existing) return existing;

  const pending = initializeProgressRepository(contentVersion, databaseFactory);
  repositoryPromises.set(contentVersion, pending);
  return pending;
}

export function snapshotFromExport(data: ProgressExportV1): LearnerSnapshot {
  return cloneSnapshot({ meta: data.meta, lessons: data.lessons });
}
