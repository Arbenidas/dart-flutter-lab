# Operación de la plataforma

Aplicación Astro estática publicada en Netlify, con Firebase Hosting conservado como alternativa. Requiere Node.js 24.16.0 y npm 11.13.0; no necesita secretos, login ni backend.

## Desarrollo y validación

```sh
npm ci
npm run dev
npm run check
npm test
npm run test:e2e
npm run test:lighthouse
```

`test:e2e` construye el sitio antes de iniciar `astro preview`. La primera ejecución local necesita los navegadores Playwright:

```sh
npx playwright install chromium firefox webkit
```

La matriz cubre Chromium, Firefox, WebKit, anchos de 375/768/1440 px, deep links, 404, funcionamiento de lectura sin JavaScript, descarga del starter y violaciones WCAG serias/críticas.

El validador independiente comprueba IDs, slugs, orden, pertenencia entre rutas/módulos/lecciones, ciclos de prerrequisitos, los movimientos que exige el `kind` de cada lección, el presupuesto de minutos por sesión, fuentes oficiales, comandos FVM compatibles con cada workspace y targets locales. Un target inexistente bloquea un módulo `available`; en `preview` o `roadmap` solo produce una advertencia.

## Artefactos

```sh
npm run lab:bundle
npm run build
```

- `public/downloads/dart_lab_starter.zip`: starter reproducible sin soluciones y con lockfile.
- `public/downloads/dart_lab_starter.manifest.json`: tamaño, cantidad de archivos y SHA-256.
- `dist/`: salida estática de Astro y el índice Pagefind.
- `playwright-report/`, `test-results/`, `lighthouse-results/`: diagnósticos locales/CI no versionados.

## Netlify

Producción: [dart-flutter-lab.netlify.app](https://dart-flutter-lab.netlify.app/).

La configuración versionada vive en `../netlify.toml`. Construye desde la raíz para que los cambios en `dart_lab/`, `.fvmrc`, `METODO.md` y `tool/` también regeneren el ZIP descargable. Netlify fija Node/npm, ejecuta `npm ci`, establece `SITE_URL` con el dominio principal y publica `platform/dist` sin fallback SPA.

Para un despliegue manual:

```sh
cd ..
SITE_URL=https://dart-flutter-lab.netlify.app npm --prefix platform run build
netlify deploy --prod --dir=platform/dist
```

Los encabezados de seguridad y caché se declaran en `netlify.toml`. El sitio `netlify.app` queda como canonical; al conectar un dominio propio hay que convertirlo en dominio principal y volver a desplegar.

## Firebase Hosting

No se versiona `.firebaserc` porque el ID de proyecto cambia por entorno. Después de crear el proyecto Firebase:

```sh
npm run build
npx firebase-tools login
npx firebase-tools use --add
npx firebase-tools emulators:start --only hosting
npx firebase-tools deploy --only hosting
```

Para sitemap y canonicales de producción, construye con la URL pública:

```sh
SITE_URL=https://TU_PROYECTO.web.app npm run build
```

`firebase.json` sirve `platform/dist`, conserva las URLs con slash final, aplica caché larga solo a assets con hash y añade una CSP limitada al mismo origen, Pagefind WASM y su worker. No hay rewrite SPA: todas las rutas desplegadas deben existir en el build estático.

## CI

`.github/workflows/ci.yml` separa tres contratos:

- Platform: contenido, tipos, lint/formato, unitarias, Playwright y Lighthouse.
- Dart Lab: formato, análisis y contrato público; no intenta resolver los `TODO` del estudiante.
- Flutter Lab: análisis, unit/widget tests y build web con Flutter 3.47.1.

Los reportes web se conservan siete días cuando GitHub Actions los genera.
