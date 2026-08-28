---
id: 'F05-L02'
trackId: 'flutter'
moduleId: 'F05'
kind: 'taller'
order: 1
slug: 'feature-first-mantiene-junta-una-capacidad'
title: 'Feature-first mantiene junta una capacidad'
summary: 'Compara agrupar por tipo con agrupar por capacidad, midiendo cuántas carpetas toca un cambio real.'
estimatedMinutes: 45
objectives:
  - 'Explicar la diferencia entre organizar por tipo y organizar por feature.'
  - 'Medir una estructura por cuántas carpetas toca un cambio típico.'
  - 'Ubicar código compartido sin convertirlo en un cajón de sastre.'
prerequisites: ['F05-L01']
activities:
  - id: 'predecir-carpetas'
    kind: 'attempt'
    prompt: 'Sin mirar el proyecto, escribe cuántas carpetas tocarías para agregar un campo etiqueta a una entrada, primero con una estructura por tipo y después con una feature-first.'
    required: true
    hints:
      - 'Cuenta modelo, repositorio, estado, vista y prueba.'
      - 'La pregunta no es cuántos archivos, es cuántos lugares distintos.'
  - id: 'recorrer-estructura'
    kind: 'evidence'
    prompt: 'Recorre lib/features/journal y anota qué hay en data y qué hay en presentation. Ejecuta el análisis del proyecto y pega la salida.'
    required: true
    hints:
      - 'Fíjate qué carpeta contiene el modelo y cuál el estado de la interfaz.'
      - 'core guarda lo que de verdad comparten varias features.'
  - id: 'sustentar-estructura'
    kind: 'source'
    prompt: 'En Guide to app architecture, encuentra qué recomienda sobre organizar el código de una aplicación y anota el encabezado.'
    required: true
    sourceLabel: 'Guide to app architecture'
    hints:
      - 'Busca la sección sobre estructura de carpetas o de proyecto.'
      - 'Anota si nombra features o capas como criterio principal.'
  - id: 'defender-core'
    kind: 'judgment'
    prompt: 'Decide qué debe entrar en core y qué no, y nombra la señal de que core se convirtió en un cajón de sastre.'
    required: true
    hints:
      - 'Algo entra en core cuando lo usan al menos dos features de verdad, no cuando podría usarse.'
      - 'Un core que crece más rápido que las features es una señal.'
docRefs:
  - label: 'Guide to app architecture'
    url: 'https://docs.flutter.dev/app-architecture/guide'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Common architecture concepts'
    url: 'https://docs.flutter.dev/app-architecture/concepts'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Por qué feature-first reduce distancia cognitiva frente a agrupar por tipo?'
  - 'En una hoja en blanco, dibuja la estructura de carpetas de la bitácora sin mirar el proyecto.'
  - 'Explica en voz alta cómo mides si una estructura de carpetas está ayudando.'
  - 'Propón la estructura de una segunda feature para esta app y decide qué compartiría con journal.'
lab:
  workspace: 'flutter_lab'
  targetPath: 'lib/features/journal'
  testCommand: 'fvm flutter test'
  analyzeCommand: 'fvm flutter analyze'
---

Dos proyectos con exactamente el mismo código pueden ser muy distintos de mantener según cómo estén repartidos los archivos.

## Dos formas de agrupar

```text
por tipo                        feature-first
lib/                            lib/
├── models/                     ├── core/
├── repositories/               │   └── theme/
├── viewmodels/                 └── features/
├── views/                          └── journal/
└── widgets/                            ├── data/
                                        └── presentation/
```

La primera agrupa **cosas que se parecen**. La segunda agrupa **cosas que cambian juntas**.

## La medida que importa

Agrega un campo `etiqueta` a una entrada. Cuenta cuántos lugares distintos tienes que abrir:

- Por tipo: `models/`, `repositories/`, `viewmodels/`, `views/`, `widgets/` y la carpeta de pruebas. Seis lugares, todos lejos entre sí.
- Feature-first: `features/journal/` y su carpeta de pruebas. Dos.

El código es el mismo. Lo que cambia es cuánto tienes que saltar para hacer un cambio completo — y, sobre todo, cuánto riesgo hay de **olvidarte** de uno de los saltos.

## Dentro de la feature sí hay capas

Feature-first no elimina las capas; las mete dentro de la feature:

```text
features/journal/
├── data/
│   ├── models/journal_entry.dart
│   ├── journal_repository.dart          ← el contrato
│   └── in_memory_journal_repository.dart ← una implementación
└── presentation/
    ├── journal_state.dart
    ├── journal_view_model.dart
    ├── journal_view.dart
    └── widgets/
```

Fíjate en el detalle de `data/`: el contrato y su implementación están separados en dos archivos. Eso es lo que permitirá sustituir uno por otro en las pruebas, que es el tema de F05-L05.

## core no es «lo demás»

`core/` guarda lo que comparten varias features **de verdad**: el tema, utilidades transversales. La tentación es meter ahí todo lo que no se sabe dónde poner.

La regla: algo entra en `core` cuando **dos features ya lo usan**, no cuando parece que podría usarse. Un `core` que crece más rápido que las features es la señal de que se volvió un cajón de sastre.

## Intento · antes de mirar

Cuenta, antes de abrir el proyecto, cuántas carpetas tocarías para agregar un campo `etiqueta` en cada una de las dos estructuras. Anota también qué archivo se te olvidaría con más facilidad en cada caso.

## Evidencia · ejecuta y compara

Recorre `lib/features/journal` y anota qué hay en `data/` y qué en `presentation/`. Después ejecuta:

```bash
cd flutter_lab
fvm flutter analyze
```

Pega la salida. Experimento útil: busca en el proyecto cuántos archivos importan `journal_entry.dart`. Esa cuenta te dice cuánto se propagaría un cambio en el modelo.

## Fuente · lee con una pregunta

Abre **Guide to app architecture** y busca la sección sobre estructura de proyecto. Pregunta concreta: ¿usa features o capas como criterio principal de agrupación? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende qué debe entrar en `core` en esta app. Después nombra la señal de alarma: cuando alguien crea `core/utils/helpers.dart`, ya se perdió el criterio.

Nombra también el costo real de feature-first: código duplicado entre features que hacen cosas parecidas, y la discusión recurrente sobre cuándo extraer.

En la próxima lección aparece el mecanismo que sostiene todo esto: el `Notifier`.
