---
id: 'D04-L06'
trackId: 'dart'
moduleId: 'D04'
kind: 'taller'
order: 5
slug: 'medir-una-accion'
title: 'Recibir una acción y medirla'
summary: 'Trabaja con void Function(), mide con Stopwatch y descubre por qué una medición suelta no es un benchmark.'
estimatedMinutes: 45
objectives:
  - 'Distinguir una función que devuelve un valor de una que solo produce efectos.'
  - 'Medir la duración de una acción con Stopwatch.'
  - 'Explicar por qué una sola medición no permite comparar dos implementaciones.'
prerequisites: ['D04-L05']
activities:
  - id: 'predecir-medicion'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, escribe cómo medirías cuánto tarda una acción y qué diferencia hay entre void Function() e int Function().'
    required: true
    hints:
      - 'Una acción que no devuelve nada solo se puede observar por sus efectos.'
      - 'Hay que arrancar el cronómetro antes y detenerlo después.'
  - id: 'resolver-m05-6'
    kind: 'evidence'
    prompt: 'Implementa medirMilisegundos con un Stopwatch, ejecuta sus pruebas y pega la salida.'
    required: true
    hints:
      - 'Stopwatch se arranca, se ejecuta la acción y se detiene.'
      - 'La propiedad de milisegundos transcurridos ya existe: no la calcules tú.'
  - id: 'sustentar-void'
    kind: 'source'
    prompt: 'En Functions, encuentra qué significa void como tipo de retorno y en qué se diferencia de una función que devuelve un valor ignorado.'
    required: true
    sourceLabel: 'Functions'
    hints:
      - 'Busca la sección sobre return values.'
      - 'Fíjate si la página dice qué devuelve una función sin return explícito.'
  - id: 'defender-benchmark'
    kind: 'judgment'
    prompt: 'Decide si una sola llamada a medirMilisegundos basta para afirmar que una implementación es más rápida que otra, y nombra qué falta.'
    required: true
    hints:
      - 'La primera ejecución paga costos que las siguientes no pagan.'
      - 'Una medición sin repeticiones ni entorno controlado es una anécdota.'
docRefs:
  - label: 'Functions'
    url: 'https://dart.dev/language/functions'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Built-in types'
    url: 'https://dart.dev/language/built-in-types'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué significa que un parámetro sea void Function()?'
  - 'En un archivo vacío, vuelve a escribir medirMilisegundos sin mirar tu solución.'
  - 'Explica en voz alta por qué una sola medición no alcanza para comparar dos implementaciones.'
  - 'Mide dos formas de construir el mismo texto y escribe qué te faltaría para que la comparación fuera confiable.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m05_funciones.dart'
  testCommand: 'fvm dart test test/m05_funciones_test.dart --name m05-6'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm05-6'
  revealReference: true
---

El módulo cierra con un tipo de función que todavía no habías usado y con una advertencia sobre medir.

## Una función que no devuelve nada

```dart
int medirMilisegundos(void Function() accion) { ... }
```

`void Function()` es _«una función que no recibe nada y no devuelve nada»_. Solo se la puede observar por sus **efectos**: lo que imprime, lo que guarda, lo que cambia.

En Flutter es la firma más común de todas: `onPressed`, `onTap`, el callback de `setState`. Vale la pena reconocerla a primera vista.

## Medir con Stopwatch

```dart
final cronometro = Stopwatch()..start();
accion();
cronometro.stop();
return cronometro.elapsedMilliseconds;
```

Arrancar, ejecutar, detener, leer. No calcules la diferencia a mano con `DateTime`: `Stopwatch` existe precisamente para esto y no se ve afectado por cambios del reloj del sistema.

## Una medición no es un benchmark

Y aquí está la parte importante de la lección. Tu función devuelve un número, y ese número **no** sirve para afirmar que una implementación es más rápida que otra:

- La **primera** ejecución paga costos que las siguientes no: compilación, cachés frías, memoria que hay que pedir.
- Una sola muestra no distingue la señal del ruido; en tu máquina hay otros procesos corriendo.
- Sin repeticiones y sin descartar valores extremos, dos ejecuciones del mismo código dan números distintos.

Medir está bien. Concluir a partir de una medición es lo que produce las afirmaciones de rendimiento que circulan sin fundamento. En D14 vas a montar un entorno donde la comparación signifique algo.

## Intento · antes de mirar

Escribe el cuerpo de memoria y anota qué diferencia hay entre `void Function()` e `int Function()` desde el punto de vista de quien la recibe.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m05_funciones_test.dart --name m05-6
```

Pega la salida. Después ejecuta tu función dos veces sobre la **misma** acción y compara los dos números. Esa diferencia, sin haber cambiado nada, es el argumento de la sección anterior.

## Fuente · lee con una pregunta

Abre **Functions** y busca qué significa `void` como tipo de retorno. Pregunta extra: ¿qué devuelve una función que no tiene `return` explícito? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende una postura: ¿alcanza una llamada a `medirMilisegundos` para decir «esta versión es más rápida»? Nombra qué agregarías —repeticiones, calentamiento, descartar extremos, entorno controlado— y qué cuesta agregarlo.

Cierra el módulo con la verificación completa del laboratorio:

```bash
./lab verify
fvm dart analyze
```

Ya tienes tipos, ausencia, decisiones y funciones. Con eso alcanza para modelar datos de verdad, que es lo que empieza en D05.
