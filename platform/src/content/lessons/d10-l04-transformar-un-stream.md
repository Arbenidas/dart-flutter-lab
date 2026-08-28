---
id: 'D10-L04'
trackId: 'dart'
moduleId: 'D10'
kind: 'taller'
order: 3
slug: 'transformar-y-recolectar-un-stream'
title: 'Transformar un stream sin perder lo que ya llegó'
summary: 'Encadena where y map sobre un stream y recolecta tolerando un fallo a mitad de camino.'
estimatedMinutes: 55
objectives:
  - 'Encadenar where y map sobre un Stream.'
  - 'Recolectar un stream conservando lo emitido antes de un fallo.'
  - 'Explicar por qué un fallo a mitad de stream necesita una decisión explícita.'
prerequisites: ['D10-L03']
activities:
  - id: 'predecir-fallo-a-mitad'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, decide qué debería devolver una recolección de un stream que emite 1 y 2 y después falla.'
    required: true
    hints:
      - 'Descartar lo recibido es una decisión, no el comportamiento natural.'
      - 'El resultado parcial y el error son dos datos distintos.'
  - id: 'resolver-m11-5'
    kind: 'evidence'
    prompt: 'Implementa paresDuplicados y recolectar. Ejecuta sus pruebas y pega la salida del test del stream que falla a mitad.'
    required: true
    hints:
      - 'Un Stream ofrece where y map igual que un Iterable.'
      - 'await for dentro de un try conserva lo acumulado.'
  - id: 'sustentar-await-for'
    kind: 'source'
    prompt: 'En Asynchronous programming: Streams, encuentra cómo se atrapa un error dentro de un await for y qué otras formas hay de manejarlo.'
    required: true
    sourceLabel: 'Asynchronous programming: Streams'
    hints:
      - 'Busca la parte sobre errores en streams.'
      - 'Fíjate si menciona handleError.'
  - id: 'defender-parcial'
    kind: 'judgment'
    prompt: 'Decide si conviene devolver el resultado parcial o descartarlo cuando un stream falla, y nombra un dominio donde tu elección sería peligrosa.'
    required: true
    hints:
      - 'Mostrar la mitad de una lista puede parecerse a la lista completa.'
      - 'Descartar todo pierde trabajo que ya estaba hecho.'
docRefs:
  - label: 'Asynchronous programming: Streams'
    url: 'https://dart.dev/libraries/async/using-streams'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Error handling'
    url: 'https://dart.dev/language/error-handling'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué conserva una recolección que atrapa el fallo dentro del await for?'
  - 'En un archivo vacío, vuelve a escribir recolectar sin mirar tu solución.'
  - 'Explica en voz alta por qué un fallo a mitad de un stream necesita una decisión explícita.'
  - 'Diseña la firma de un repositorio que obtenga una configuración una vez y observe cambios posteriores.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m11_asincronia.dart'
  testCommand: 'fvm dart test test/m11_asincronia_test.dart --name m11-5'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm11-5'
  revealReference: true
---

Un `Stream` tiene los mismos operadores que un `Iterable`. Lo que cambia es qué ocurre cuando algo falla **a mitad**.

## Transformar es igual

```dart
Stream<int> paresDuplicados(Stream<int> origen) =>
    origen.where((n) => n.isEven).map((n) => n * 2);
```

`where` y `map` devuelven otro `Stream`. Nada se ejecuta hasta que alguien escucha, igual que con `Iterable`.

## El fallo a mitad de camino

```dart
Future<({List<int> valores, String? error})> recolectar(Stream<int> origen) async {
  final valores = <int>[];
  try {
    await for (final valor in origen) {
      valores.add(valor);
    }
    return (valores: valores, error: null);
  } catch (error) {
    return (valores: valores, error: error.toString());
  }
}
```

La clave está en dónde se declara `valores`: **fuera** del `try`. Cuando el stream falla después de emitir 1 y 2, esos dos siguen ahí.

Es la misma forma del lote de D09-L04: el resultado parcial y el motivo del fallo viajan juntos, y el tipo obliga a quien llame a ver los dos.

## Un stream falla una vez

Un `Stream` termina de una de dos maneras: se cierra bien o **falla**. Después de un error el stream está terminado; no sigue emitiendo. Por eso «lo que alcanzó a llegar» es una cantidad fija y tiene sentido devolverla.

`handleError` permite interceptar el error y seguir con el stream original en algunos casos, pero eso ya es otro contrato.

## Intento · antes de mirar

Decide qué debería devolver `recolectar` para un stream que emite `1`, `2` y después lanza. Anota las dos opciones —conservar o descartar— y cuál te parece el comportamiento por defecto correcto.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m11_asincronia_test.dart --name m11-5
```

Pega la salida del test del stream que falla a mitad. Experimento: mueve la declaración de `valores` **dentro** del `try` y observa qué test se rompe.

## Fuente · lee con una pregunta

Abre **Asynchronous programming: Streams** y busca la parte de errores. Pregunta concreta: ¿cómo se atrapa un error dentro de un `await for` y qué alternativas hay? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende conservar el resultado parcial. El riesgo es real: media lista mostrada sin aviso se parece demasiado a la lista completa, y quien la mire tomará decisiones con datos incompletos.

Nombra cómo lo evitarías —el campo `error` no nulo es exactamente esa señal— y en qué dominio preferirías descartar todo.

Cierra el módulo:

```bash
fvm dart analyze
```

En D11 el problema deja de ser esperar y pasa a ser **no bloquear**.
