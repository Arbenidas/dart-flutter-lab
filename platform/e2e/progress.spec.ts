import { readFile } from 'node:fs/promises';

import { expect, test, type Page } from '@playwright/test';

const lessonId = 'D00-L01';
const lessonUrl = '/lecciones/como-estudiar-programacion/';
const lessonTitle = 'Tu primer programa en Dart';

async function readStoredLesson(page: Page): Promise<unknown> {
  return page.evaluate(
    async ({ databaseName, targetLessonId }) => {
      const databases = await indexedDB.databases();
      if (!databases.some((database) => database.name === databaseName)) return null;
      return new Promise((resolvePromise, rejectPromise) => {
        const openRequest = indexedDB.open(databaseName);
        openRequest.onerror = () => rejectPromise(openRequest.error);
        openRequest.onsuccess = () => {
          const database = openRequest.result;
          if (!database.objectStoreNames.contains('lessonProgress')) {
            database.close();
            resolvePromise(null);
            return;
          }
          const transaction = database.transaction('lessonProgress', 'readonly');
          const request = transaction.objectStore('lessonProgress').get(targetLessonId);
          request.onerror = () => rejectPromise(request.error);
          request.onsuccess = () => resolvePromise(request.result ?? null);
          transaction.oncomplete = () => database.close();
        };
      });
    },
    { databaseName: 'dart_flutter_lab', targetLessonId: lessonId },
  );
}

async function openFirstLesson(page: Page): Promise<void> {
  await page.goto(lessonUrl);
  await expect(page.getByRole('heading', { level: 1, name: lessonTitle })).toBeVisible();
  await expect.poll(() => readStoredLesson(page)).not.toBeNull();
}

async function saveNote(page: Page, note: string): Promise<void> {
  const noteField = page.getByLabel('Tu nota de la lección');
  await noteField.fill(note);
  await expect(page.locator('[data-save-status]')).toHaveText('Nota guardada en este navegador.');
}

async function completeLesson(page: Page): Promise<void> {
  const firstHint = page.locator('details[data-hint-id]').first();
  await firstHint.locator('summary').click();
  await expect(firstHint).toHaveAttribute('data-revealed', 'true');

  const requiredActivities = page.locator(
    '[data-activity][data-required="true"] input[data-activity-check]',
  );
  const requiredCount = await requiredActivities.count();
  expect(requiredCount).toBeGreaterThan(0);
  for (let index = 0; index < requiredCount; index += 1) {
    await requiredActivities.nth(index).check();
  }

  const confirm = page.locator('[data-confirm-lesson]');
  await expect(confirm).toBeEnabled();
  await confirm.click();
  await expect(confirm).toHaveText('Confirmado por mí');
  await expect(page.locator('[data-lesson-stamp]')).toHaveText('Confirmado por ti');
  await expect(page.locator('[data-debrief] > summary')).toBeVisible();
}

test('state: una nota, respuesta y evidencia sobreviven la recarga y aparecen en notas/progreso', async ({
  page,
}) => {
  const note = 'Pensaba que ejecutar y analizar eran lo mismo; ahora distingo ambos contratos.';
  const response = 'Primero predigo dos líneas y luego comparo el orden real.';
  await openFirstLesson(page);

  const responseField = page.locator('[data-activity-response]').first();
  await responseField.fill(response);
  await responseField.blur();
  await page.locator('[data-activity-check]').first().check();
  await saveNote(page, note);

  await page.reload();
  await expect(page.getByLabel('Tu nota de la lección')).toHaveValue(note);
  await expect(page.locator('[data-activity-response]').first()).toHaveValue(response);
  await expect(page.locator('[data-activity-check]').first()).toBeChecked();

  await page.goto('/notas/');
  await expect(page.locator('[data-notes-status]')).toHaveText('1 nota visible.');
  await expect(page.getByText(note, { exact: true })).toBeVisible();

  await page.goto('/progreso/');
  await expect(page.locator('[data-count-started]')).toHaveText('1');
  await expect(page.locator('[data-count-completed]')).toHaveText('0');
});

test('state: revelar una pista y completar la lección habilita un debrief persistente', async ({
  page,
}) => {
  await openFirstLesson(page);
  await completeLesson(page);

  await page.locator('[data-debrief] > summary').click();
  await expect(page.locator('[data-debrief]')).toContainText('¿Qué supuesto hizo tu versión?');

  await page.reload();
  await expect(page.locator('[data-lesson-stamp]')).toHaveText('Confirmado por ti');
  await expect(page.locator('details[data-hint-id]').first()).toHaveAttribute(
    'data-revealed',
    'true',
  );
  await expect(page.locator('[data-debrief] > summary')).toBeVisible();
});

test('state: una lección completada entra al repaso al día siguiente', async ({ page }) => {
  await page.clock.install({ time: new Date('2026-08-23T12:00:00.000Z') });
  await openFirstLesson(page);
  await completeLesson(page);

  await page.clock.setSystemTime(new Date('2026-08-25T12:00:00.000Z'));
  await page.goto('/repasos/');
  await expect(page.getByRole('heading', { level: 3, name: lessonTitle })).toBeVisible();
  await expect(page.getByText('Repaso 1 de 4', { exact: false })).toBeVisible();

  await page.getByRole('button', { name: 'Lo expliqué sin ayuda' }).click();
  await expect(
    page.getByRole('heading', { level: 3, name: 'No hay repasos vencidos' }),
  ).toBeVisible();
});

test('state: una nota se sincroniza entre dos pestañas sin recargar', async ({ context, page }) => {
  const note = 'Esta nota llegó a otra pestaña mediante el repositorio local.';
  await openFirstLesson(page);
  const notesPage = await context.newPage();
  await notesPage.goto('/notas/');
  await expect(notesPage.locator('[data-notes-status]')).toHaveText('0 notas visibles.');

  await saveNote(page, note);
  await expect(notesPage.locator('[data-notes-status]')).toHaveText('1 nota visible.');
  await expect(notesPage.getByText(note, { exact: true })).toBeVisible();
  await notesPage.close();
});

test('state: exportar, borrar e importar restaura el estado validado', async ({ page }) => {
  const note = 'Respaldo verificable para probar el ciclo completo de datos locales.';
  await openFirstLesson(page);
  await saveNote(page, note);
  await page.goto('/ajustes/datos/');

  const [exportDownload] = await Promise.all([
    page.waitForEvent('download'),
    page.getByRole('button', { name: 'Exportar JSON' }).click(),
  ]);
  expect(exportDownload.suggestedFilename()).toMatch(
    /^flutter-lab-progreso-\d{4}-\d{2}-\d{2}\.json$/,
  );
  const exportPath = await exportDownload.path();
  expect(exportPath).not.toBeNull();
  const exportedText = await readFile(exportPath!, 'utf8');
  const exported = JSON.parse(exportedText) as { format?: string; lessons?: unknown[] };
  expect(exported.format).toBe('flutter-lab-progress');
  expect(exported.lessons).toHaveLength(1);

  await page.getByRole('button', { name: 'Borrar datos locales' }).click();
  const clearDialog = page.getByRole('dialog', { name: 'Confirma el borrado' });
  await clearDialog.getByLabel('Palabra de confirmación').fill('BORRAR');
  await Promise.all([
    page.waitForURL(/\/inicio\/$/),
    clearDialog.getByRole('button', { name: 'Borrar definitivamente' }).click(),
  ]);
  await page.goto('/notas/');
  await expect(
    page.getByRole('heading', { level: 2, name: 'Tu cuaderno está vacío' }),
  ).toBeVisible();

  await page.goto('/ajustes/datos/');
  await page.locator('[data-import-file]').setInputFiles({
    name: 'respaldo.json',
    mimeType: 'application/json',
    buffer: Buffer.from(exportedText),
  });
  await expect(page.locator('[data-import-preview]')).toBeVisible();
  await expect(page.locator('[data-preview-lessons]')).toHaveText('1');
  await expect(page.locator('[data-preview-notes]')).toHaveText('1');

  const priorBackup = page.waitForEvent('download');
  await page.getByRole('button', { name: 'Reemplazar datos' }).click();
  await priorBackup;
  await expect(page.locator('[data-import-status]')).toContainText(
    'la copia sustituyó el estado local en una sola transacción',
  );

  await page.goto('/notas/');
  await expect(page.getByText(note, { exact: true })).toBeVisible();
});
