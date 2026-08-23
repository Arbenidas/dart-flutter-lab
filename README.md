# Dart & Flutter Lab

[![CI](https://github.com/Arbenidas/dart-flutter-lab/actions/workflows/ci.yml/badge.svg)](https://github.com/Arbenidas/dart-flutter-lab/actions/workflows/ci.yml)
[![Licencia MIT](https://img.shields.io/badge/licencia-MIT-151515.svg)](LICENSE)
[![Sitio](https://img.shields.io/badge/demo-Netlify-B7F43C.svg)](https://dart-flutter-lab.netlify.app/)

Plataforma de estudio y laboratorios locales para aprender programación desde cero sin delegar el razonamiento. La teoría, las pistas socráticas, las notas y los repasos viven en la web; el código se compila, analiza y prueba con los SDK reales en tu computadora.

**Demo pública:** [dart-flutter-lab.netlify.app](https://dart-flutter-lab.netlify.app/)

## Estructura

```text
flutter-lab/
├── .fvmrc              # Flutter 3.47.1 (incluye Dart 3.13)
├── METODO.md           # ciclo PENSAR y reglas de práctica
├── docs/               # guía curricular para contribuir contenido
├── tool/preflight.sh   # comprueba FVM y las versiones requeridas
├── platform/           # plataforma Astro, progreso local y contenido
├── dart_lab/           # ejercicios Dart deliberadamente incompletos
└── flutter_lab/        # app Bitácora: MVVM feature-first + Riverpod
```

La plataforma no requiere login. Guarda progreso, notas y repasos en IndexedDB del navegador y permite exportar/importar una copia JSON. Los laboratorios tampoco llaman a un backend.

## Requisitos reproducibles

- [FVM](https://fvm.app/) para usar la versión fijada por `.fvmrc`.
- Node.js 24.16.0 y npm 11.13.0 para `platform/` (fijados en `.nvmrc` y `packageManager`).
- Chrome/Chromium, Firefox y WebKit para la matriz web completa.

Instala y comprueba el SDK desde la raíz:

```sh
fvm install
./tool/preflight.sh
```

El preflight exige Flutter `3.47.1` y Dart `3.13.x`.

Si usas NVM, prepara también la herramienta web:

```sh
nvm install
nvm use
npm --version
```

## Levantar la plataforma

```sh
cd platform
npm ci
npm run dev
```

Astro publica el entorno local en `http://localhost:4321`. Los comandos principales son:

```sh
npm run check          # tipos, contenido, ESLint y Prettier
npm test               # pruebas unitarias de progreso/importación
npm run build          # starter ZIP + validación + sitio estático + Pagefind
npm run test:e2e       # build y Playwright en tres motores/tres anchos
npm run test:lighthouse
```

Antes del primer E2E local instala sus navegadores:

```sh
npx playwright install chromium firefox webkit
```

`npm run lab:bundle` regenera `public/downloads/dart_lab_starter.zip`. El archivo conserva `pubspec.lock` y los ejecutables `tool/preflight.sh`/`dart_lab/lab`, pero excluye `dart_lab/soluciones/`, artefactos de build y progreso local. Su manifiesto incluye tamaño y SHA-256.

Consulta [platform/README.md](platform/README.md) para Netlify, Firebase Hosting, artefactos y diagnóstico de CI.

## Trabajar en Dart Lab

```sh
cd dart_lab
fvm dart pub get --enforce-lockfile
fvm dart run bin/m01_hola.dart
./lab next
./lab status
```

`m01_hola.dart` corresponde a D00 y no tiene tests. A partir de D01,
`./lab next` ejecuta solo el siguiente ejercicio pendiente. Los `TODO` y sus
tests fallidos son el punto de partida, no un fallo del repositorio. Cuando
completes todo:

```sh
./lab verify
fvm dart analyze
fvm dart format .
```

Las soluciones están en `dart_lab/soluciones/`; consúltalas únicamente después de predecir, intentar, leer el error y acudir a la documentación oficial.

## Ejecutar Flutter Lab

```sh
cd flutter_lab
fvm flutter pub get --enforce-lockfile
fvm flutter run -d chrome
```

La app Bitácora es un CRUD en memoria que muestra el flujo `View → ViewModel → Repository` con Riverpod `Notifier`, sin generación de código. Los ejercicios guiados F00–F06 están en `flutter_lab/docs/`.

Verificación completa:

```sh
fvm flutter analyze
fvm flutter test
fvm flutter build web --release
```

## Método de trabajo

Cada práctica sigue PENSAR: **Predice, Escribe, Nombra, Sustenta, Argumenta y Reaplica**. Lee [METODO.md](METODO.md) antes de pedir una solución completa. La documentación oficial de partida está en [dart.dev](https://dart.dev/), [api.dart.dev](https://api.dart.dev/), [docs.flutter.dev](https://docs.flutter.dev/) y [api.flutter.dev](https://api.flutter.dev/).

## Contribuir

Issues y pull requests son bienvenidos. Antes de un cambio grande, abre una propuesta para acordar alcance y evitar trabajo duplicado.

- [Guía de contribución](CONTRIBUTING.md)
- [Guía curricular](docs/CURRICULUM.md)
- [Roadmap](ROADMAP.md)
- [Código de conducta](CODE_OF_CONDUCT.md)
- [Política de seguridad](SECURITY.md)

Para empezar, busca issues con `good first issue` o `help wanted`. La rama `main` está protegida: todo cambio debe entrar mediante un pull request revisado y con la CI verde.

## Licencia

Código y documentación se publican bajo la [licencia MIT](LICENSE).
