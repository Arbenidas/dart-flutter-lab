import { expect, test } from '@playwright/test';

const visualProjects = new Set(['chromium-375', 'chromium-768', 'chromium-1440']);

test('smoke: la portada conserva su composición visual en los tres anchos objetivo', async ({
  page,
}) => {
  test.skip(
    !visualProjects.has(test.info().project.name),
    'Las referencias visuales se mantienen en Chromium para evitar baselines redundantes.',
  );
  await page.emulateMedia({ reducedMotion: 'reduce' });
  await page.goto('/');
  await page.evaluate(() => document.fonts.ready);

  await expect(page).toHaveScreenshot('portada.png', {
    animations: 'disabled',
    fullPage: true,
    maxDiffPixelRatio: 0.03,
    // Las fuentes locales conservan la composición, pero el antialiasing cambia
    // ligeramente entre macOS y Linux (el entorno de CI).
    threshold: 0.4,
  });
});

test('layout: no aparece scroll horizontal desde 320 px', async ({ page }) => {
  await page.setViewportSize({ width: 320, height: 800 });
  for (const path of [
    '/',
    '/inicio/',
    '/ruta/',
    '/lecciones/como-estudiar-programacion/',
    '/ajustes/datos/',
  ]) {
    await page.goto(path);
    const dimensions = await page.evaluate(() => ({
      clientWidth: document.documentElement.clientWidth,
      scrollWidth: document.documentElement.scrollWidth,
    }));
    expect(dimensions.scrollWidth, `${path} desborda a 320 px`).toBeLessThanOrEqual(
      dimensions.clientWidth,
    );
  }
});
