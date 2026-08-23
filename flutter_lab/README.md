# Flutter Lab v1 — Bitácora

Laboratorio Flutter Web mínimo y ejecutable. La misma feature enseña una
separación profesional sin introducir Clean Architecture antes de necesitarla:

```text
JournalView -> JournalViewModel -> JournalRepository
                                      |
                                      -> InMemoryJournalRepository
```

- La **View** renderiza estado y reenvía eventos.
- El **ViewModel** valida y coordina los comandos CRUD.
- El **Repository** es la fuente de verdad.
- Riverpod conecta las dependencias con `Notifier`, sin code generation.
- Los datos viven en memoria y se reinician al recargar. Eso es deliberado en v1.

## Requisitos

- FVM con Flutter 3.47.1 fijado por `.fvmrc`
- Dart 3.13.x incluido en ese SDK
- Chrome u otro navegador soportado por Flutter Web

## Ejecutar

```bash
./tool/preflight.sh
cd flutter_lab
fvm flutter pub get
fvm flutter run -d chrome
```

## Verificar

```bash
fvm flutter analyze
fvm flutter test
fvm flutter build web --release
```

## Recorrido F00–F06

Los ejercicios están en [`docs/`](docs/). Sigue el orden y modifica una copia o
una rama de práctica; la app incluida es la referencia funcional que permite
comparar tus decisiones después de intentarlo.

1. F00 — entorno y ciclo de trabajo
2. F01 — widgets y composición
3. F02 — constraints y responsive
4. F03 — estado local y formularios
5. F04 — navegación, tema y accesibilidad
6. F05 — MVVM feature-first + Riverpod
7. F06 — unit y widget tests
