import AxeBuilder from '@axe-core/playwright';
import { expect, test } from '@playwright/test';
import { createHash } from 'node:crypto';

const expectedStarterEntries = [
  '.fvmrc',
  'LEEME.md',
  'METODO.md',
  'tool/preflight.sh',
  'dart_lab/lab',
  'dart_lab/pubspec.yaml',
  'dart_lab/pubspec.lock',
  'dart_lab/bin/m01_hola.dart',
  'dart_lab/bin/lab.dart',
  'dart_lab/test/public_contract_test.dart',
];
const forbiddenStarterEntries = [
  'dart_lab/tool/verify_reference.dart',
  'dart_lab/tool/fixtures/mutants.json',
];
const forbiddenStarterPrefixes = ['dart_lab/soluciones/'];

function readZipEntryNames(body: Buffer): string[] {
  const endSignature = 0x06054b50;
  const centralSignature = 0x02014b50;
  const firstPossibleEnd = Math.max(0, body.byteLength - 65_557);
  let endOffset = body.byteLength - 22;
  while (endOffset >= firstPossibleEnd && body.readUInt32LE(endOffset) !== endSignature) {
    endOffset -= 1;
  }
  if (endOffset < firstPossibleEnd) throw new Error('El ZIP no contiene un directorio central.');

  const entryCount = body.readUInt16LE(endOffset + 10);
  let offset = body.readUInt32LE(endOffset + 16);
  const names: string[] = [];
  for (let index = 0; index < entryCount; index += 1) {
    if (body.readUInt32LE(offset) !== centralSignature) {
      throw new Error(`Entrada ZIP inválida en el byte ${offset}.`);
    }
    const nameLength = body.readUInt16LE(offset + 28);
    const extraLength = body.readUInt16LE(offset + 30);
    const commentLength = body.readUInt16LE(offset + 32);
    names.push(body.subarray(offset + 46, offset + 46 + nameLength).toString('utf8'));
    offset += 46 + nameLength + extraLength + commentLength;
  }
  return names;
}

test('smoke: la portada comunica el método y permite abrir la ruta', async ({ page }) => {
  await page.goto('/');

  await expect(page).toHaveTitle(/Dart & Flutter Lab/);
  await expect(
    page.getByRole('heading', { level: 1, name: 'Aprende sin delegar el pensamiento.' }),
  ).toBeVisible();
  await page.getByRole('link', { name: 'Ruta', exact: true }).first().click();
  await expect(page).toHaveURL(/\/ruta\/$/);
  await expect(
    page.getByRole('heading', { level: 1, name: 'El orden evita la magia.' }),
  ).toBeVisible();
});

for (const route of [
  { path: '/inicio/', heading: 'Prepara un lugar donde equivocarte.' },
  { path: '/hoy/', heading: 'Una misión a la vez.' },
  { path: '/ruta/', heading: 'El orden evita la magia.' },
]) {
  test(`smoke: la ruta ${route.path} admite carga directa`, async ({ page }) => {
    const response = await page.goto(route.path);
    expect(response?.status()).toBe(200);
    await expect(page.getByRole('heading', { level: 1, name: route.heading })).toBeVisible();
  });
}

test('smoke: el starter contiene el contrato público y excluye la referencia', async ({
  page,
  request,
}) => {
  await page.goto('/inicio/');
  const downloadLink = page.getByRole('link', { name: 'Descargar laboratorio Dart' });
  await expect(downloadLink).toHaveAttribute('href', '/downloads/dart_lab_starter.zip');

  const response = await request.get('/downloads/dart_lab_starter.zip');
  expect(response.status()).toBe(200);
  const body = await response.body();
  expect(body.byteLength).toBeGreaterThan(1_000);
  expect(body.subarray(0, 2).toString('hex')).toBe('504b');

  const manifestResponse = await request.get('/downloads/dart_lab_starter.manifest.json');
  expect(manifestResponse.status()).toBe(200);
  const manifest = (await manifestResponse.json()) as {
    bytes: number;
    excludedEntries: string[];
    excludedPrefixes: string[];
    fileCount: number;
    requiredEntries: string[];
    sha256: string;
  };
  expect(manifest.requiredEntries).toEqual(expectedStarterEntries);
  expect(manifest.excludedEntries).toEqual(forbiddenStarterEntries);
  expect(manifest.excludedPrefixes).toEqual(forbiddenStarterPrefixes);
  expect(manifest.bytes).toBe(body.byteLength);
  expect(manifest.sha256).toBe(createHash('sha256').update(body).digest('hex'));

  const entries = readZipEntryNames(body);
  expect(entries).toHaveLength(manifest.fileCount);
  for (const requiredEntry of expectedStarterEntries) expect(entries).toContain(requiredEntry);
  for (const forbiddenEntry of forbiddenStarterEntries) {
    expect(entries).not.toContain(forbiddenEntry);
  }
  for (const forbiddenPrefix of forbiddenStarterPrefixes) {
    expect(entries.some((entry) => entry.startsWith(forbiddenPrefix))).toBe(false);
  }
});

test('smoke: una lección admite deep link y recarga directa', async ({ page }) => {
  const response = await page.goto('/lecciones/como-estudiar-programacion/');
  expect(response?.status()).toBe(200);
  await expect(
    page.getByRole('heading', { level: 1, name: 'Tu primer programa en Dart' }),
  ).toBeVisible();
  await page.reload();
  await expect(page).toHaveURL(/\/lecciones\/como-estudiar-programacion\/$/);
  await expect(
    page.getByRole('heading', { level: 1, name: 'Tu primer programa en Dart' }),
  ).toBeVisible();
});

test('smoke: una URL inexistente devuelve la página 404', async ({ page }) => {
  const response = await page.goto('/esta-ruta-no-existe/');
  expect(response?.status()).toBe(404);
  await expect(
    page.getByRole('heading', { level: 1, name: 'Esta página no forma parte del mapa.' }),
  ).toBeVisible();
});

test('sin JavaScript la lección conserva teoría, navegación y documentación', async ({ page }) => {
  const response = await page.goto('/lecciones/como-estudiar-programacion/');
  expect(response?.status()).toBe(200);
  await expect(
    page.getByRole('heading', { level: 1, name: 'Tu primer programa en Dart' }),
  ).toBeVisible();
  // La actividad de Fuente y el panel lateral enlazan la misma referencia declarada.
  await expect(page.getByRole('link', { name: 'dart run' }).first()).toBeVisible();
  expect(await page.getByRole('link', { name: 'dart run' }).count()).toBe(2);
  await expect(
    page.getByRole('link', { name: 'Descargar laboratorio Dart' }).first(),
  ).toBeVisible();
  await expect(page.locator('main')).toContainText('Esta sí es una lección de Dart');
  await expect(page.locator('main')).toContainText('fvm dart run bin/m01_hola.dart');
});

test('smoke: la portada no tiene violaciones WCAG serias o críticas', async ({ page }) => {
  await page.goto('/');
  const results = await new AxeBuilder({ page }).withTags(['wcag2a', 'wcag2aa']).analyze();
  const blocking = results.violations.filter((violation) =>
    ['critical', 'serious'].includes(violation.impact ?? ''),
  );
  expect(blocking).toEqual([]);
});

test('teclado: permite saltar al contenido y abrir la búsqueda sin ratón', async ({ page }) => {
  await page.goto('/');

  const skipLink = page.getByRole('link', { name: 'Saltar al contenido' });
  await page.keyboard.press('Tab');
  await expect(skipLink).toBeFocused();
  await page.keyboard.press('Enter');
  await expect(page.locator('main')).toBeFocused();

  await page.keyboard.press('/');
  const search = page.getByRole('searchbox', { name: 'Concepto, error o API' });
  await expect(search).toBeFocused();
  await expect(page.getByRole('dialog', { name: 'Busca una duda concreta' })).toBeVisible();
});

test('búsqueda: Pagefind encuentra lecciones y aplica el filtro de ruta', async ({ page }) => {
  await page.goto('/');
  await page.keyboard.press('/');
  await page.getByRole('searchbox', { name: 'Concepto, error o API' }).fill('Future');
  await page.locator('[data-search-track]').selectOption('dart');

  await expect(page.locator('[data-search-status]')).toContainText('resultados visibles', {
    timeout: 10_000,
  });
  expect(await page.locator('[data-search-results] a').count()).toBeGreaterThan(0);
  await expect(page.locator('[data-search-results]')).toContainText('Future');
});

test('smoke: el onboarding explica el entorno y enlaza la primera práctica', async ({ page }) => {
  await page.goto('/inicio/');

  for (const heading of [
    'Instala Flutter 3.47.1',
    'Descarga el starter',
    'Resuelve dependencias',
    'Comprueba el primer archivo',
  ]) {
    await expect(page.getByRole('heading', { level: 2, name: heading })).toBeVisible();
  }
  for (const command of [
    './tool/preflight.sh',
    'fvm dart pub get --enforce-lockfile',
    'fvm dart run bin/m01_hola.dart',
  ]) {
    await expect(page.getByText(command, { exact: true })).toBeVisible();
  }
  await expect(page.getByRole('link', { name: 'Empezar la primera lección' })).toHaveAttribute(
    'href',
    '/lecciones/como-estudiar-programacion/',
  );
});
