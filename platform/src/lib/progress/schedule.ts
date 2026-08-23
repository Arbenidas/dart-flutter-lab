import type { LessonProgressRecord, ReviewProgress } from './types';

export const REVIEW_INTERVAL_DAYS = [1, 3, 7, 21] as const;

function addUtcDays(date: Date, days: number): string {
  const next = new Date(date);
  next.setUTCDate(next.getUTCDate() + days);
  return next.toISOString();
}

export function scheduleFirstReview(completedAt: Date): ReviewProgress {
  return {
    stage: 0,
    dueAtUtc: addUtcDays(completedAt, REVIEW_INTERVAL_DAYS[0]),
  };
}

export function advanceReview(
  progress: LessonProgressRecord,
  recalledWithoutHelp: boolean,
  reviewedAt: Date,
): LessonProgressRecord {
  if (progress.retainedAtUtc) return progress;
  let review = progress.review;
  if (!review) {
    if (!progress.completedAtUtc) {
      throw new Error('No se puede registrar un repaso antes de completar la lección.');
    }
    review = scheduleFirstReview(new Date(progress.completedAtUtc));
  }
  const reviewedAtUtc = reviewedAt.toISOString();

  if (!recalledWithoutHelp) {
    return {
      ...progress,
      review: {
        ...review,
        dueAtUtc: addUtcDays(reviewedAt, 1),
        lastReviewedAtUtc: reviewedAtUtc,
      },
      updatedAtUtc: reviewedAtUtc,
    };
  }

  if (review.stage === 3) {
    return {
      ...progress,
      retainedAtUtc: reviewedAtUtc,
      review: {
        stage: review.stage,
        lastReviewedAtUtc: reviewedAtUtc,
      },
      updatedAtUtc: reviewedAtUtc,
    };
  }

  const nextStage = (review.stage + 1) as 1 | 2 | 3;
  return {
    ...progress,
    review: {
      stage: nextStage,
      dueAtUtc: addUtcDays(reviewedAt, REVIEW_INTERVAL_DAYS[nextStage]),
      lastReviewedAtUtc: reviewedAtUtc,
    },
    updatedAtUtc: reviewedAtUtc,
  };
}

export function isReviewDue(progress: LessonProgressRecord, now = new Date()): boolean {
  if (!progress.review?.dueAtUtc || progress.retainedAtUtc) return false;
  const dueAt = Date.parse(progress.review.dueAtUtc);
  return Number.isFinite(dueAt) && dueAt <= now.getTime();
}
