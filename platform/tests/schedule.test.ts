import { describe, expect, it } from 'vitest';

import {
  advanceReview,
  deriveLessonStatus,
  isReviewDue,
  REVIEW_INTERVAL_DAYS,
  scheduleFirstReview,
} from '../src/lib/progress';
import type { LessonProgressRecord } from '../src/lib/progress';

const completed: LessonProgressRecord = {
  lessonId: 'd01-tipos',
  startedAtUtc: '2026-01-01T12:00:00.000Z',
  lastOpenedAtUtc: '2026-01-01T12:00:00.000Z',
  completedAtUtc: '2026-01-01T12:00:00.000Z',
  attemptCount: 1,
  completedActivityIds: ['predict'],
  responsesByActivityId: {},
  revealedHintIds: [],
  note: '',
  updatedAtUtc: '2026-01-01T12:00:00.000Z',
};

describe('agenda de repasos', () => {
  it('declara la secuencia completa 1, 3, 7 y 21', () => {
    expect(REVIEW_INTERVAL_DAYS).toEqual([1, 3, 7, 21]);
  });

  it('agenda el primer repaso al día siguiente', () => {
    expect(scheduleFirstReview(new Date('2026-01-01T12:00:00.000Z')).dueAtUtc).toBe(
      '2026-01-02T12:00:00.000Z',
    );
  });

  it('avanza por 3, 7 y 21 días antes de retener', () => {
    let progress: LessonProgressRecord = {
      ...completed,
      review: scheduleFirstReview(new Date(completed.completedAtUtc!)),
    };
    progress = advanceReview(progress, true, new Date('2026-01-02T12:00:00.000Z'));
    expect(progress.review?.stage).toBe(1);
    expect(progress.review?.dueAtUtc).toBe('2026-01-05T12:00:00.000Z');
    progress = advanceReview(progress, true, new Date('2026-01-05T12:00:00.000Z'));
    expect(progress.review?.stage).toBe(2);
    expect(progress.review?.dueAtUtc).toBe('2026-01-12T12:00:00.000Z');
    progress = advanceReview(progress, true, new Date('2026-01-12T12:00:00.000Z'));
    expect(progress.review?.stage).toBe(3);
    expect(progress.review?.dueAtUtc).toBe('2026-02-02T12:00:00.000Z');
    progress = advanceReview(progress, true, new Date('2026-02-02T12:00:00.000Z'));
    expect(deriveLessonStatus(progress)).toBe('retained');
    expect(progress.review).toEqual({
      stage: 3,
      lastReviewedAtUtc: '2026-02-02T12:00:00.000Z',
    });
  });

  it('repite la etapa al día siguiente cuando todavía cuesta', () => {
    const progress = advanceReview(
      { ...completed, review: { stage: 2, dueAtUtc: '2026-01-08T12:00:00.000Z' } },
      false,
      new Date('2026-01-08T12:00:00.000Z'),
    );
    expect(progress.review).toEqual({
      stage: 2,
      dueAtUtc: '2026-01-09T12:00:00.000Z',
      lastReviewedAtUtc: '2026-01-08T12:00:00.000Z',
    });
  });

  it('no inventa una agenda si la lección no fue completada', () => {
    const inProgress = { ...completed };
    delete inProgress.completedAtUtc;
    expect(() => advanceReview(inProgress, true, new Date())).toThrow(
      'No se puede registrar un repaso antes de completar la lección.',
    );
  });

  it('calcula vencimientos inclusivos e ignora fechas inválidas o retención', () => {
    const review = {
      ...completed,
      review: { stage: 0 as const, dueAtUtc: '2026-01-02T12:00:00.000Z' },
    };
    expect(isReviewDue(review, new Date('2026-01-02T11:59:59.999Z'))).toBe(false);
    expect(isReviewDue(review, new Date('2026-01-02T12:00:00.000Z'))).toBe(true);
    expect(isReviewDue({ ...review, retainedAtUtc: '2026-01-02T12:00:00.000Z' })).toBe(false);
    expect(isReviewDue({ ...review, review: { stage: 0, dueAtUtc: 'no-es-fecha' } })).toBe(false);
  });
});
