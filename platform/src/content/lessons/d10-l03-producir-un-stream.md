---
id: 'D10-L03'
trackId: 'dart'
moduleId: 'D10'
kind: 'taller'
order: 2
slug: 'producir-un-stream-con-async'
title: 'Un Stream entrega muchos valores a lo largo del tiempo'
summary: 'Produce una secuencia asíncrona con async* y yield, y compara su contrato con el de un Future.'
estimatedMinutes: 50
objectives:
  - 'Declarar una función generadora asíncrona con async* y yield.'
  - 'Distinguir el contrato de Future<T> del de Stream<T>.'
  - 'Validar un argumento en una función que produce un stream.'
prerequisites: ['D10-L02']
activities:
  - id: 'predecir-stream'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, escribe qué emite contarHasta para 4, para 0 y para -1, y decide en qué momento se produce el fallo del argumento negativo.'
    required: true
    hints:
      - 'Un stream puede no emitir nada y aun así completarse bien.'
      - 'Un generador no ejecuta su cuerpo hasta que alguien se suscribe.'
  - id: 'resolver-m11-4'
    kind: 'evidence'
    prompt: 'Implementa contarHasta con async* y ejecuta sus pruebas. Pega la salida del caso del argumento negativo.'
    required: true
    hints:
      - 'yield emite un valor y sigue.'
      - 'toList sobre un stream devuelve un Future con todo lo emitido.'
  - id: 'sustentar-streams'
    kind: 'source'
    prompt: 'En Asynchronous programming: Streams, encuentra qué garantiza un Stream frente a un Future y cómo se consume uno.'
    required: true
    sourceLabel: 'Asynchronous programming: Streams'
    hints:
      - 'Busca la comparación entre Future y Stream.'
      - 'Fíjate en await for y en las alternativas.'
  - id: 'defender-stream-o-future'
    kind: 'judgment'
    prompt: 'Decide si una operación que devuelve una lista completa debería exponer Future<List<T>> o Stream<T>, y nombra qué le cuesta a quien la consume.'
    required: true
    hints:
      - 'Un Future entrega todo junto y obliga a esperar al último elemento.'
      - 'Un Stream permite mostrar lo que va llegando y complica el consumo.'
docRefs:
  - label: 'Asynchronous programming: Streams'
    url: 'https://dart.dev/libraries/async/using-streams'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Asynchronous programming'
    url: 'https://dart.dev/libraries/async/async-await'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué separa el contrato de Future<T> del de Stream<T>?'
  - 'En un archivo vacío, vuelve a escribir contarHasta con async* sin mirar tu solución.'
  - 'Explica en voz alta cuándo se ejecuta el cuerpo de un generador asíncrono.'
  - 'Escribe un stream que emita los caracteres de un texto y decide si merece ser un stream.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m11_asincronia.dart'
  testCommand: 'fvm dart test test/m11_asincronia_test.dart --name m11-4'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm11-4'
---

Un `Future` promete **un** valor, alguna vez. Un `Stream` promete **cero o más**, a lo largo del tiempo, y después termina — o falla.

## Producir con `async*`

```dart
Stream<int> contarHasta(int n) async* {
  if (n < 0) {
    throw RangeError.value(n, 'n', 'Debe ser cero o mayor');
  }
  for (var i = 1; i <= n; i++) {
    yield i;
  }
}
```

`async*` marca una **función generadora asíncrona**. `yield` emite un valor y continúa; cuando el cuerpo termina, el stream se cierra.

## El cuerpo no corre hasta que alguien escucha

Ese `throw` del principio no ocurre al llamar `contarHasta(-1)`. Ocurre cuando alguien se **suscribe**:

```dart
final stream = contarHasta(-1); // no pasa nada
await stream.toList();          // aquí lanza
```

Es la misma pereza de D05-L05, ahora en el mundo asíncrono. Y por eso el test escribe `expect(contarHasta(-1).toList(), throwsRangeError)` en lugar de envolver la llamada en una función.

## Cero valores es un resultado válido

`contarHasta(0)` no emite nada y **se completa bien**. Un stream vacío no es un error, igual que una lista vacía no lo es. Confundir «no llegó nada» con «algo falló» es el bug clásico al consumir streams.

## Tres formas de consumir

```dart
await for (final valor in stream) { }  // el más legible
final todos = await stream.toList();   // junta todo, exige que termine
stream.listen((valor) { });            // sin await, hay que cancelar
```

`toList()` sobre un stream infinito nunca completa. `listen` devuelve una suscripción que hay que cancelar, o se queda viva.

## Intento · antes de mirar

Escribe qué emite `contarHasta` para `4`, `0` y `-1`, y **en qué momento** falla el último caso.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m11_asincronia_test.dart --name m11-4
```

Pega la salida del caso negativo.

## Fuente · lee con una pregunta

Abre **Asynchronous programming: Streams** con una pregunta concreta: ¿qué garantiza un `Stream` que un `Future` no? Anota el encabezado y las formas de consumirlo.

## Criterio · decide y acepta el costo

Una operación devuelve una lista completa. ¿`Future<List<T>>` o `Stream<T>`?

El `Future` entrega todo junto y obliga a esperar al último elemento antes de mostrar nada. El `Stream` permite ir mostrando y le traslada a quien consume el trabajo de acumular, manejar la finalización y cancelar.

Elige y nombra el costo. En la última lección del módulo el stream se transforma y se recolecta.
