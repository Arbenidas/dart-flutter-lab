export const PROGRESS_FORMAT = 'flutter-lab-progress' as const;
export const PROGRESS_SCHEMA_VERSION = 1 as const;
export const MAX_IMPORT_BYTES = 2 * 1024 * 1024;
export const MAX_IDENTIFIER_LENGTH = 160;
export const MAX_NOTE_LENGTH = 10_000;
export const MAX_RESPONSE_LENGTH = 5_000;

export type LessonStatus = 'not_started' | 'in_progress' | 'completed' | 'retained';

export interface AppMetaRecord {
  key: 'state';
  schemaVersion: typeof PROGRESS_SCHEMA_VERSION;
  contentVersionSeen: string;
  revision: number;
  updatedAtUtc: string;
  lastLessonId?: string;
}

export interface ReviewProgress {
  stage: 0 | 1 | 2 | 3;
  dueAtUtc?: string;
  lastReviewedAtUtc?: string;
}

export interface LessonProgressRecord {
  lessonId: string;
  startedAtUtc: string;
  lastOpenedAtUtc: string;
  completedAtUtc?: string;
  retainedAtUtc?: string;
  attemptCount: number;
  completedActivityIds: string[];
  responsesByActivityId: Record<string, string>;
  revealedHintIds: string[];
  note: string;
  noteUpdatedAtUtc?: string;
  review?: ReviewProgress;
  updatedAtUtc: string;
}

export interface LearnerSnapshot {
  meta: AppMetaRecord;
  lessons: LessonProgressRecord[];
}

export interface ProgressExportV1 {
  format: typeof PROGRESS_FORMAT;
  schemaVersion: typeof PROGRESS_SCHEMA_VERSION;
  exportedAtUtc: string;
  appVersion: string;
  contentVersion: string;
  meta: AppMetaRecord;
  lessons: LessonProgressRecord[];
}

export interface ImportPreview {
  lessonCount: number;
  noteCount: number;
  completedCount: number;
  retainedCount: number;
  exportedAtUtc: string;
  contentVersion: string;
  data: ProgressExportV1;
}

export function deriveLessonStatus(progress?: LessonProgressRecord): LessonStatus {
  if (!progress) return 'not_started';
  if (progress.retainedAtUtc) return 'retained';
  if (progress.completedAtUtc) return 'completed';
  return 'in_progress';
}
