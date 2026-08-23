import Dexie, { type EntityTable } from 'dexie';

import type { AppMetaRecord, LessonProgressRecord } from './types';

export const DATABASE_NAME = 'dart_flutter_lab';

export type LabDatabase = Dexie & {
  meta: EntityTable<AppMetaRecord, 'key'>;
  lessonProgress: EntityTable<LessonProgressRecord, 'lessonId'>;
};

export function createDatabase(name = DATABASE_NAME): LabDatabase {
  const database = new Dexie(name) as LabDatabase;
  database.version(1).stores({
    meta: '&key, updatedAtUtc, revision',
    lessonProgress: '&lessonId, updatedAtUtc, completedAtUtc, retainedAtUtc, review.dueAtUtc',
  });
  return database;
}
