---
id: 'D10-L01'
trackId: 'dart'
moduleId: 'D10'
kind: 'taller'
order: 0
slug: 'futures-y-streams'
title: 'Todo lo anterior al primer await es síncrono'
summary: 'Comprueba con una bitácora qué parte de una función async corre antes de devolver el control a quien la llamó.'
estimatedMinutes: 50
objectives:
  - 'Explicar qué se ejecuta antes de que una función async devuelva su Future.'
  - 'Distinguir llamar a una función async de esperar su resultado.'
  - 'Reconocer que async no significa en paralelo.'
prerequisites: ['D09-L05']
activities:
  - id: 'predecir-orden-async'
    kind: 'attempt'
    prompt: 'Sin ejecutar nada, numera las líneas de una función async que imprime antes y después de un await, mientras quien la llama imprime inmediatamente después de invocarla.'
    required: true
    hints:
      - 'Marcar una función async no la manda a otro hilo.'
      - 'El primer await es donde la función devuelve el control.'
  - id: 'resolver-m11-1'
    kind: 'evidence'
    prompt: 'Implementa ordenDeEjecucion y ejecuta sus pruebas. Pega la salida del test que comprueba la bitácora sin haber esperado el Future.'
    required: true
    hints:
      - 'La primera anotación ocurre antes de que la función devuelva nada.'
      - 'La segunda solo aparece después de que el Future se complete.'
  - id: 'sustentar-async'
    kind: 'source'
    prompt: 'En Asynchronous programming, encuentra qué devuelve una función marcada async y en qué momento devuelve el control.'
    required: true
    sourceLabel: 'Asynchronous programming'
    hints:
      - 'Busca la parte sobre cómo funcionan async y await.'
      - 'Fíjate en qué pasa con el código anterior al primer await.'
  - id: 'defender-async'
    kind: 'judgment'
    prompt: 'Decide si conviene marcar async una función que no espera nada, y nombra qué cambia para quien la llama.'
    required: true
    hints:
      - 'Marcarla async cambia su tipo de retorno y obliga a esperar.'
      - 'Devolver Future desde una función síncrona a veces estabiliza una interfaz.'
docRefs:
  - label: 'Asynchronous programming'
    url: 'https://dart.dev/libraries/async/async-await'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Functions'
    url: 'https://dart.dev/language/functions'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué parte de una función async se ejecuta antes de devolver el control al llamador?'
  - 'En un archivo vacío, vuelve a escribir ordenDeEjecucion sin mirar tu solución.'
  - 'Explica en voz alta por qué async no significa en paralelo.'
  - 'Toma una función async de otro proyecto y marca dónde cede el turno.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m11_asincronia.dart'
  testCommand: 'fvm dart test test/m11_asincronia_test.dart --name m11-1'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm11-1'
---

`async` es una de las palabras peor entendidas del lenguaje. No manda nada a otro hilo. No paraleliza. Solo permite que la función **ceda el turno** en cada `await`.

## Qué corre y cuándo

```dart
Future<List<String>> ordenDeEjecucion(List<String> bitacora) async {
  bitacora.add('antes del await');
  await Future<void>.delayed(Duration.zero);
  bitacora.add('despues del await');
  return bitacora;
}
```

Cuando alguien la llama:

1. El cuerpo empieza a ejecutarse **de inmediato y de forma síncrona**.
2. `'antes del await'` ya está en la lista.
3. Al llegar al `await`, la función devuelve un `Future` sin terminar y **el control vuelve a quien llamó**.
4. Más tarde, el resto del cuerpo continúa.

Por eso este test puede comprobar el primer elemento sin haber esperado nada:

```dart
unawaited(ordenDeEjecucion(bitacora));
expect(bitacora, <String>['antes del await']);
```

## `Duration.zero` también cede

`await Future<void>.delayed(Duration.zero)` no espera tiempo y **sí** cede el turno. El `await` no es una pausa: es un punto de cesión. Todo lo que esté encolado corre antes de que tu función continúe.

## Llamar no es esperar

```dart
hacerAlgo();        // arranca y sigo
await hacerAlgo();  // arranca y espero
```

Las dos son válidas. La primera con una función que puede fallar es un peligro: el error queda sin atrapar y va a parar al manejador global. `unawaited` existe para decir «sé lo que hago» de forma explícita.

## Intento · antes de mirar

Numera el orden de estas cinco líneas:

```dart
void main() async {
  print('1');
  final futuro = trabajo(); // trabajo imprime '2', await, imprime '4'
  print('3');
  await futuro;
  print('5');
}
```

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m11_asincronia_test.dart --name m11-1
```

Pega la salida del test que comprueba la bitácora sin esperar. Si tu implementación pusiera la primera anotación después del `await`, ese test lo detecta.

## Fuente · lee con una pregunta

Abre **Asynchronous programming** con una pregunta concreta: ¿qué pasa con el código anterior al primer `await`? Anota el encabezado.

## Criterio · decide y acepta el costo

¿Conviene marcar `async` una función que hoy no espera nada? Cambia el tipo de retorno a `Future` y obliga a todos sus llamadores a esperar. A cambio, si mañana necesita esperar algo, la interfaz ya está lista y nadie tiene que cambiar.

Elige y nombra el costo. En la próxima lección aparecen dos esperas y la pregunta de si van una detrás de otra.
