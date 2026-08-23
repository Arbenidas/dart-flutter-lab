import { getCollection, type CollectionEntry } from 'astro:content';

export type TrackEntry = CollectionEntry<'tracks'>;
export type ModuleEntry = CollectionEntry<'modules'>;
export type LessonEntry = CollectionEntry<'lessons'>;

export interface Catalog {
  tracks: TrackEntry[];
  modules: ModuleEntry[];
  lessons: LessonEntry[];
}

export async function getCatalog(): Promise<Catalog> {
  const [tracks, modules, lessons] = await Promise.all([
    getCollection('tracks'),
    getCollection('modules'),
    getCollection('lessons'),
  ]);

  tracks.sort((left, right) => left.data.order - right.data.order);
  const trackOrder = new Map(tracks.map((entry, index) => [entry.data.id, index]));
  modules.sort((left, right) => {
    const byTrack =
      (trackOrder.get(left.data.trackId) ?? 0) - (trackOrder.get(right.data.trackId) ?? 0);
    return byTrack || left.data.order - right.data.order;
  });
  const moduleOrder = new Map(modules.map((entry, index) => [entry.data.id, index]));
  lessons.sort((left, right) => {
    const byModule =
      (moduleOrder.get(left.data.moduleId) ?? 0) - (moduleOrder.get(right.data.moduleId) ?? 0);
    return byModule || left.data.order - right.data.order;
  });

  const catalog = { tracks, modules, lessons };
  validateCatalog(catalog);
  return catalog;
}

export function validateCatalog(catalog: Catalog): void {
  const moduleIdList = catalog.modules.map((entry) => entry.data.id);
  const lessonIdList = catalog.lessons.map((entry) => entry.data.id);
  const moduleSlugs = catalog.modules.map((entry) => entry.data.slug);
  const lessonSlugs = catalog.lessons.map((entry) => entry.data.slug);
  const moduleIds = new Set(moduleIdList);
  const lessonIds = new Set(lessonIdList);
  const duplicateIds = <T>(values: T[]) =>
    values.filter((value, index) => values.indexOf(value) !== index);

  const duplicatedModules = duplicateIds(moduleIdList);
  const duplicatedLessons = duplicateIds(lessonIdList);
  if (
    duplicatedModules.length ||
    duplicatedLessons.length ||
    duplicateIds(moduleSlugs).length ||
    duplicateIds(lessonSlugs).length
  ) {
    throw new Error('El catálogo contiene identificadores duplicados.');
  }

  for (const track of catalog.tracks) {
    for (const moduleId of track.data.moduleIds) {
      if (!moduleIds.has(moduleId))
        throw new Error(`La ruta ${track.data.id} referencia ${moduleId}, que no existe.`);
    }
  }

  for (const module of catalog.modules) {
    const parentTrack = catalog.tracks.find((track) => track.data.id === module.data.trackId);
    if (!parentTrack?.data.moduleIds.includes(module.data.id)) {
      throw new Error(`${module.data.id} no está declarado en la ruta ${module.data.trackId}.`);
    }
    for (const prerequisite of module.data.prerequisites) {
      if (!moduleIds.has(prerequisite))
        throw new Error(`${module.data.id} depende de ${prerequisite}, que no existe.`);
    }
    for (const lessonId of module.data.lessonIds) {
      if (!lessonIds.has(lessonId))
        throw new Error(`${module.data.id} referencia ${lessonId}, que no existe.`);
      const lesson = catalog.lessons.find((entry) => entry.data.id === lessonId);
      if (lesson?.data.moduleId !== module.data.id) {
        throw new Error(
          `${lessonId} está declarado en ${module.data.id}, pero pertenece a ${lesson?.data.moduleId}.`,
        );
      }
    }
  }

  for (const lesson of catalog.lessons) {
    const module = catalog.modules.find((entry) => entry.data.id === lesson.data.moduleId);
    if (!module?.data.lessonIds.includes(lesson.data.id)) {
      throw new Error(`${lesson.data.id} no está declarado en el módulo ${lesson.data.moduleId}.`);
    }
    for (const prerequisite of lesson.data.prerequisites) {
      if (!lessonIds.has(prerequisite)) {
        throw new Error(`${lesson.data.id} depende de ${prerequisite}, que no existe.`);
      }
    }
  }

  const visiting = new Set<string>();
  const visited = new Set<string>();
  const modulesById = new Map(catalog.modules.map((entry) => [entry.data.id, entry]));
  const visit = (id: string) => {
    if (visited.has(id)) return;
    if (visiting.has(id)) throw new Error(`Los prerrequisitos contienen un ciclo en ${id}.`);
    visiting.add(id);
    for (const dependency of modulesById.get(id)?.data.prerequisites ?? []) visit(dependency);
    visiting.delete(id);
    visited.add(id);
  };
  for (const id of moduleIds) visit(id);

  const visitingLessons = new Set<string>();
  const visitedLessons = new Set<string>();
  const lessonsById = new Map(catalog.lessons.map((entry) => [entry.data.id, entry]));
  const visitLesson = (id: string) => {
    if (visitedLessons.has(id)) return;
    if (visitingLessons.has(id))
      throw new Error(`Los prerrequisitos de lecciones contienen un ciclo en ${id}.`);
    visitingLessons.add(id);
    for (const dependency of lessonsById.get(id)?.data.prerequisites ?? []) visitLesson(dependency);
    visitingLessons.delete(id);
    visitedLessons.add(id);
  };
  for (const id of lessonIds) visitLesson(id);
}

export function lessonHref(lesson: LessonEntry): string {
  return `/lecciones/${lesson.data.slug}/`;
}

export function moduleHref(module: ModuleEntry): string {
  return `/ruta/${module.data.slug}/`;
}

export function lessonClientCatalog(lessons: LessonEntry[]) {
  return lessons.map((lesson) => ({
    id: lesson.data.id,
    title: lesson.data.title,
    slug: lesson.data.slug,
    moduleId: lesson.data.moduleId,
    href: lessonHref(lesson),
  }));
}
