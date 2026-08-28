---
id: 'D11-L05'
trackId: 'dart'
moduleId: 'D11'
kind: 'taller'
order: 4
slug: 'ver-el-bloqueo-en-una-bitacora'
title: 'Ver el bloqueo, no imaginarlo'
summary: 'Programa un temporizador junto a un ciclo pesado y comprueba en qué orden ocurren de verdad.'
estimatedMinutes: 45
objectives:
  - 'Demostrar que un ciclo síncrono retrasa un temporizador del mismo isolate.'
  - 'Explicar cómo funciona la cola del bucle de eventos.'
  - 'Elegir entre trocear un cálculo y moverlo a otro isolate.'
prerequisites: ['D11-L04']
activities:
  - id: 'predecir-temporizador'
    kind: 'attempt'
    prompt: 'Sin ejecutar nada, predice el orden en que aparecen las anotaciones si programas un temporizador de duración cero y después corres un ciclo pesado.'
    required: true
    hints:
      - 'El temporizador se encola; no se ejecuta al programarlo.'
      - 'La cola solo avanza cuando el código en curso termina o cede.'
  - id: 'resolver-m12-5'
    kind: 'evidence'
    prompt: 'Implementa bloqueaElIsolate y ejecuta sus pruebas. Pega la salida del test que comprueba cuál anotación va primero.'
    required: true
    hints:
      - 'Timer.run encola una tarea para el próximo turno del bucle.'
      - 'Después del ciclo hace falta un await para dejar que la cola avance.'
  - id: 'sustentar-event-loop'
    kind: 'source'
    prompt: 'En Isolates, encuentra cómo describe la documentación la cola del bucle de eventos y cuándo se atienden las tareas encoladas.'
    required: true
    sourceLabel: 'Isolates'
    hints:
      - 'Busca event loop y event queue.'
      - 'Anota el encabezado y el orden que describe.'
  - id: 'defender-trocear'
    kind: 'judgment'
    prompt: 'Decide entre trocear un cálculo largo en pasos que cedan el turno y moverlo entero a otro isolate, y nombra el costo de cada opción.'
    required: true
    hints:
      - 'Trocear mantiene el acceso a la memoria del isolate y complica el código.'
      - 'Mover a otro isolate obliga a copiar y a que el trabajo sea autónomo.'
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
  - '¿Cuándo elegirías Isolate.run y cuándo trocear el trabajo en el isolate actual?'
  - 'En un archivo vacío, vuelve a escribir bloqueaElIsolate sin mirar tu solución.'
  - 'Explica en voz alta cómo avanza la cola del bucle de eventos.'
  - 'Mide el retraso de un temporizador con y sin un ciclo pesado delante, y escribe qué te faltaría para que la medición fuera confiable.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m12_isolates.dart'
  testCommand: 'fvm dart test test/m12_isolates_test.dart --name m12-5'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm12-5'
  revealReference: true
---

La primera lección del módulo afirmó que un ciclo bloquea su isolate. Esta lo demuestra con un orden que se puede comprobar.

## El experimento

```dart
Future<List<String>> bloqueaElIsolate(int vueltas) async {
  final bitacora = <String>[];
  Timer.run(() => bitacora.add('temporizador'));
  sumaDeCuadrados(vueltas);
  bitacora.add('ciclo');
  await Future<void>.delayed(Duration.zero);
  return bitacora;
}
```

`Timer.run` **encola** una tarea para el próximo turno del bucle. No la ejecuta ahí mismo.

Después corre el ciclo, que no cede el turno. Cuando termina, se anota `'ciclo'`. Solo entonces el `await` devuelve el control al bucle, que atiende la cola y ejecuta el temporizador.

Resultado: `['ciclo', 'temporizador']`. Siempre, aunque el temporizador se programara antes y con duración cero.

## La cola

El bucle de eventos toma tareas de una cola y las ejecuta **de a una hasta el final**. No hay expropiación: nada interrumpe una tarea en curso.

Por eso «duración cero» significa «en cuanto pueda», no «ahora». Y por eso un ciclo de un segundo retrasa un segundo todo lo que hubiera encolado, incluidas las animaciones de una interfaz.

## Dos salidas

| Estrategia | Cómo                                               | Costo                                          |
| ---------- | -------------------------------------------------- | ---------------------------------------------- |
| trocear    | partir el ciclo y ceder con `await` cada N vueltas | complica el código, sigue usando el mismo hilo |
| mover      | `Isolate.run`                                      | copia de datos, el trabajo debe ser autónomo   |

Trocear conserva el acceso a toda la memoria del isolate y ensucia el código con puntos de cesión. Mover deja el código limpio y exige que todo lo necesario pueda copiarse.

## Intento · antes de mirar

Predice el orden de las anotaciones. Después predice qué pasaría si quitaras el `await` final.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m12_isolates_test.dart --name m12-5
```

Pega la salida del test que comprueba cuál anotación va primero. Experimento: cambia `sumaDeCuadrados(vueltas)` por `await sumaDeCuadradosEnIsolate(vueltas)` y observa cómo cambia el orden.

## Fuente · lee con una pregunta

Abre **Isolates** y busca _event queue_. Pregunta concreta: ¿cuándo se atienden las tareas encoladas? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende trocear o mover para un caso concreto: parsear un archivo de veinte megabytes.

Cierra el módulo:

```bash
fvm dart analyze
```

En D12 los datos dejan de ser tuyos: llegan de fuera, en texto, y hay que desconfiar de ellos.
