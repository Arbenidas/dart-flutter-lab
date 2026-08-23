import { defineCollection } from 'astro:content';
import { glob } from 'astro/loaders';
import { z } from 'astro/zod';

const trackIdSchema = z.enum(['dart', 'flutter']);
const moduleIdSchema = z.string().regex(/^(D(?:0[0-9]|1[0-5])|F0[0-6])$/);
const lessonIdSchema = z.string().regex(/^(D(?:0[0-9]|1[0-5])|F0[0-6])-L\d{2}$/);

const tracks = defineCollection({
  loader: glob({ pattern: '**/*.json', base: './src/content/tracks' }),
  schema: z.object({
    id: trackIdSchema,
    order: z.number().int().nonnegative(),
    slug: z.string().min(1),
    title: z.string().min(1),
    summary: z.string().min(1),
    promise: z.string().min(1),
    status: z.enum(['available', 'preview', 'roadmap']),
    moduleIds: z.array(moduleIdSchema).min(1),
  }),
});

const modules = defineCollection({
  loader: glob({
    pattern: '**/*.json',
    base: './src/content/modules',
    generateId: ({ entry }) => entry.replace(/\.json$/, ''),
  }),
  schema: z.object({
    id: moduleIdSchema,
    trackId: trackIdSchema,
    order: z.number().int().nonnegative(),
    slug: z.string().min(1),
    title: z.string().min(1),
    summary: z.string().min(1),
    status: z.enum(['available', 'preview', 'roadmap']),
    estimatedHours: z.number().positive(),
    prerequisites: z.array(moduleIdSchema),
    outcomes: z.array(z.string().min(1)).min(2),
    lessonIds: z.array(lessonIdSchema),
  }),
});

const activitySchema = z.object({
  id: z.string().min(1),
  kind: z.enum(['predict', 'code', 'debug', 'explain', 'transfer', 'docs']),
  prompt: z.string().min(1),
  required: z.boolean(),
  hints: z.array(z.string().min(1)).max(3),
});

const docRefSchema = z.object({
  label: z.string().min(1),
  url: z.url(),
  kind: z.enum(['guide', 'api', 'cookbook', 'package', 'changelog']),
  version: z.string().min(1),
  lastVerified: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
});

const labSchema = z.object({
  workspace: z.string().min(1),
  targetPath: z.string().min(1),
  testCommand: z.string().min(1),
  analyzeCommand: z.string().min(1),
  exerciseId: z.string().min(1).optional(),
});

const lessons = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/lessons' }),
  schema: z.object({
    id: lessonIdSchema,
    trackId: trackIdSchema,
    moduleId: moduleIdSchema,
    order: z.number().int().nonnegative(),
    slug: z.string().min(1),
    title: z.string().min(1),
    summary: z.string().min(1),
    estimatedMinutes: z.number().int().positive(),
    objectives: z.array(z.string().min(1)).min(2),
    prerequisites: z.array(lessonIdSchema),
    activities: z.array(activitySchema).min(6),
    docRefs: z.array(docRefSchema).min(1),
    reviewPrompts: z.array(z.string().min(1)).length(4),
    lab: labSchema.optional(),
  }),
});

export const collections = { tracks, modules, lessons };
