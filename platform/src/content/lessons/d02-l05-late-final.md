---
id: 'D02-L05'
trackId: 'dart'
moduleId: 'D02'
kind: 'taller'
order: 4
slug: 'late-final-es-un-contrato-tuyo'
title: 'late es una promesa que firmas vos'
summary: 'Usa late final para inicializar tarde sin volver nulable un campo, y comprueba qué pasa cuando incumples la promesa.'
estimatedMinutes: 50
objectives:
  - 'Explicar qué permite late que una declaración normal no permite.'
  - 'Distinguir un LateInitializationError de un error del analizador.'
  - 'Elegir entre late final y un campo nulable según quién debe comprobar.'
prerequisites: ['D02-L04']
activities:
  - id: 'predecir-late'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, predice qué ocurre al llamar minutosHasta antes de comenzar: ¿lo detecta el analizador, falla al ejecutar o devuelve cero?'
    required: true
    hints:
      - 'El analizador confía en la promesa que firmas con late.'
      - 'Compara con lo que pasó al mutar una lista const en D01.'
  - id: 'resolver-m03-5'
    kind: 'evidence'
    prompt: 'Declara _inicio como late final DateTime, implementa comenzar y minutosHasta, ejecuta las pruebas y pega el mensaje del caso que llama antes de comenzar.'
    required: true
    hints:
      - 'No escribas tú el throw: es late quien debe lanzarlo.'
      - 'difference entre dos DateTime te da una Duration.'
  - id: 'sustentar-late'
    kind: 'source'
    prompt: 'En Understanding null safety, encuentra qué hace la palabra late y en qué momento se comprueba la promesa.'
    required: true
    sourceLabel: 'Understanding null safety'
    hints:
      - 'Busca el encabezado sobre late variables.'
      - 'Fíjate si la página distingue error de compilación de error de ejecución.'
  - id: 'defender-late-vs-nulable'
    kind: 'judgment'
    prompt: 'Compara late final DateTime _inicio con DateTime? _inicio. Elige una para este caso y nombra a quién le trasladas el trabajo de comprobar.'
    required: true
    hints:
      - 'Con el campo nulable, cada método que lo use tiene que comprobarlo.'
      - 'Con late, la comprobación ocurre una sola vez y en tiempo de ejecución.'
docRefs:
  - label: 'Understanding null safety'
    url: 'https://dart.dev/null-safety/understanding-null-safety'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Variables'
    url: 'https://dart.dev/language/variables'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué promete late y quién paga si la promesa se incumple?'
  - 'En un archivo vacío, vuelve a escribir una clase con un campo late final y su método de inicialización, sin mirar tu solución.'
  - 'Explica en voz alta la diferencia entre un LateInitializationError y un error que atrapa el analizador.'
  - 'Toma una clase tuya con un campo nulable comprobado en cinco métodos y decide si late final la mejora; defiende la respuesta.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m03_null_safety.dart'
  testCommand: 'fvm dart test test/m03_null_safety_test.dart --name m03-5'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm03-5'
  revealReference: true
---

`late` es la palabra más malinterpretada de null safety. No es una red de seguridad: es un contrato que **vos** firmás con el compilador.

## Qué dice exactamente

```dart
late final DateTime _inicio;
```

Esto le dice al analizador: _«confía en mí, voy a asignar esto antes de que alguien lo lea»_. A cambio, el analizador deja de exigirte comprobaciones y el campo se comporta como no nulable en todo el resto de la clase.

Si mentís, no compila mal. Explota en ejecución:

```text
LateInitializationError: Field '_inicio' has not been initialized.
```

Es el mismo patrón que viste al mutar una lista `const`: el análisis estático aprueba, el objeto real rechaza. Con la diferencia de que aquí la aprobación es literalmente algo que pediste.

## Cuándo vale la pena

La alternativa es un campo nulable:

```dart
DateTime? _inicio;
```

Correcta, y con un costo repartido: **cada** método que use `_inicio` tiene que comprobarlo, aunque el diseño garantice que ya fue asignado. Con cinco métodos, son cinco comprobaciones que nunca fallan y que ensucian la lectura.

`late final` concentra esa comprobación en un solo lugar y en un solo momento. La eliges cuando el ciclo de vida del objeto garantiza el orden —primero `comenzar`, después todo lo demás— y ese orden es parte del contrato de la clase.

## Intento · antes de mirar

Predice qué ocurre en esta secuencia, indicando si falla al analizar o al ejecutar:

```dart
final sesion = SesionTimer();
sesion.minutosHasta(DateTime.now()); // sin haber llamado comenzar
```

## Evidencia · ejecuta y compara

Implementa el ejercicio y ejecuta sus pruebas:

```bash
cd dart_lab
fvm dart test test/m03_null_safety_test.dart --name m03-5
```

El test que llama antes de `comenzar` espera que **lance**. No escribas tú ese `throw`: si lo haces, el ejercicio pasa por el motivo equivocado. Deja que lo lance `late` y pega el mensaje exacto.

## Fuente · lee con una pregunta

Abre **Understanding null safety** y busca el encabezado sobre variables `late`. Pregunta concreta: ¿en qué momento se comprueba la promesa? Anota la frase que lo dice.

## Criterio · decide y acepta el costo

Defiende `late final DateTime _inicio` frente a `DateTime? _inicio` para esta clase. La respuesta útil nombra **a quién** le trasladas el trabajo: con nulable, a cada método; con `late`, a vos en el momento del diseño, y al usuario de la clase si te equivocas.

Cierra el módulo con la verificación completa:

```bash
fvm dart analyze
```

En D03 el lenguaje deja de hablar de valores y empieza a hablar de **decisiones**: ramas, patterns y exhaustividad.
