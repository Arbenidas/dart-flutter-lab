---
id: 'D11-L02'
trackId: 'dart'
moduleId: 'D11'
kind: 'taller'
order: 1
slug: 'mover-el-calculo-a-otro-isolate'
title: 'Mover el cálculo, no el problema'
summary: 'Usa Isolate.run para sacar el trabajo pesado del isolate principal y observa cómo viaja el resultado y el fallo.'
estimatedMinutes: 50
objectives:
  - 'Ejecutar una función en otro isolate con Isolate.run.'
  - 'Explicar cómo cruzan la frontera el resultado y las excepciones.'
  - 'Reconocer el costo de arrancar un isolate.'
prerequisites: ['D11-L01']
activities:
  - id: 'predecir-isolate'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, predice qué devuelve una función que corre en otro isolate y qué ocurre si esa función lanza.'
    required: true
    hints:
      - 'El resultado tiene que cruzar la frontera de alguna forma.'
      - 'Un fallo del otro lado no puede desaparecer sin más.'
  - id: 'resolver-m12-2'
    kind: 'evidence'
    prompt: 'Implementa sumaDeCuadradosEnIsolate con Isolate.run. Ejecuta sus pruebas y pega la salida del test que comprueba la propagación del fallo.'
    required: true
    hints:
      - 'Isolate.run recibe una función sin argumentos y devuelve un Future.'
      - 'El valor capturado por la closure se copia al otro isolate.'
  - id: 'sustentar-isolate-run'
    kind: 'source'
    prompt: 'En Isolates, encuentra qué hace Isolate.run y qué restricciones tiene lo que se le pasa y lo que devuelve.'
    required: true
    sourceLabel: 'Isolates'
    hints:
      - 'Busca Isolate.run en la página.'
      - 'Fíjate en qué tipos pueden cruzar la frontera.'
  - id: 'defender-costo-isolate'
    kind: 'judgment'
    prompt: 'Decide si conviene usar Isolate.run para un cálculo de un milisegundo, y nombra qué se paga al arrancar uno.'
    required: true
    hints:
      - 'Arrancar un isolate cuesta memoria y tiempo de puesta en marcha.'
      - 'Copiar datos grandes de ida y vuelta también cuesta.'
docRefs:
  - label: 'Isolates'
    url: 'https://dart.dev/language/isolates'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Asynchronous programming'
    url: 'https://dart.dev/libraries/async/async-await'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué hace Isolate.run y cómo llega el resultado de vuelta?'
  - 'En un archivo vacío, vuelve a escribir sumaDeCuadradosEnIsolate sin mirar tu solución.'
  - 'Explica en voz alta qué ocurre si la función que corre en otro isolate lanza.'
  - 'Toma un cálculo pesado tuyo y estima si el traslado compensa.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m12_isolates.dart'
  testCommand: 'fvm dart test test/m12_isolates_test.dart --name m12-2'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm12-2'
---

Cuando el cálculo no se puede acelerar, se puede **mover**.

## Una línea

```dart
Future<int> sumaDeCuadradosEnIsolate(int n) => Isolate.run(() => sumaDeCuadrados(n));
```

`Isolate.run` arranca un isolate, ejecuta la función, devuelve el resultado y lo apaga. La API de bajo nivel con puertos existe y para un cálculo puntual esto es todo lo que hace falta.

Mientras corre, el isolate principal sigue atendiendo su bucle de eventos: el temporizador dispara, la interfaz responde.

## Qué cruza la frontera

El `n` que la closure captura se **copia** al otro isolate. El resultado se copia de vuelta. No se comparte ningún objeto.

Eso tiene dos consecuencias prácticas:

1. Lo que cruce debe ser copiable. Tipos simples, listas, mapas y records sí; un socket abierto o algo que dependa de recursos del isolate original, no.
2. Copiar cuesta. Mover un cálculo sobre diez megabytes de datos paga esos diez megabytes dos veces.

## Los fallos también cruzan

Si la función lanza, el `Future` que devuelve `Isolate.run` **falla con ese error**. No se pierde ni se convierte en algo genérico:

```dart
expect(sumaDeCuadradosEnIsolate(-1), throwsA(isA<Error>()));
```

Esto es importante: el manejo de errores de D09 sigue funcionando a través de la frontera.

## Intento · antes de mirar

Predice, por escrito:

- qué tipo devuelve `sumaDeCuadradosEnIsolate`
- qué pasa si la función lanza `RangeError`
- si el otro isolate puede modificar una variable del principal

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m12_isolates_test.dart --name m12-2
```

Pega la salida del test de la propagación del fallo.

## Fuente · lee con una pregunta

Abre **Isolates** y busca `Isolate.run`. Pregunta concreta: ¿qué restricciones tiene lo que se le pasa y lo que devuelve? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende no usar `Isolate.run` para un cálculo de un milisegundo. Arrancar un isolate cuesta memoria y tiempo de puesta en marcha, y copiar los datos de ida y vuelta cuesta más. Para un trabajo corto, el traslado es más caro que el cálculo.

Nombra a partir de qué escala compensa — y fíjate en que, otra vez, no tienes con qué medirlo. En la próxima lección ese umbral se convierte en código.
