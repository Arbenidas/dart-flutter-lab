---
id: 'D11-L01'
trackId: 'dart'
moduleId: 'D11'
kind: 'taller'
order: 0
slug: 'isolates-y-concurrencia'
title: 'async no arregla un ciclo que no cede'
summary: 'Escribe un cálculo intensivo y comprueba que marcarlo async no evita que bloquee todo lo demás.'
estimatedMinutes: 50
objectives:
  - 'Distinguir una espera de entrada y salida de un trabajo intensivo de CPU.'
  - 'Explicar por qué marcar async no vuelve concurrente un ciclo.'
  - 'Reconocer qué operaciones ceden el turno y cuáles no.'
prerequisites: ['D10-L04']
activities:
  - id: 'predecir-bloqueo'
    kind: 'attempt'
    prompt: 'Sin ejecutar nada, decide cuál de estas dos permite que un temporizador siga respondiendo: esperar la lectura de un archivo, o recorrer cien millones de enteros dentro de una función async.'
    required: true
    hints:
      - 'El await es el único punto donde una función cede el turno.'
      - 'Un ciclo no tiene awaits dentro.'
  - id: 'resolver-m12-1'
    kind: 'evidence'
    prompt: 'Implementa sumaDeCuadrados con su validación y ejecuta sus pruebas. Pega la salida del caso conocido y del negativo.'
    required: true
    hints:
      - 'La suma de cuadrados de 1 a 3 es 14.'
      - 'Marcarla async cambiaría su firma sin cambiar su comportamiento.'
  - id: 'sustentar-isolates'
    kind: 'source'
    prompt: 'En Isolates, encuentra qué explica la documentación sobre el modelo de un solo hilo por isolate y el bucle de eventos.'
    required: true
    sourceLabel: 'Isolates'
    hints:
      - 'Busca event loop dentro de la página.'
      - 'Anota qué dice sobre operaciones que no ceden.'
  - id: 'defender-sincrona'
    kind: 'judgment'
    prompt: 'Decide si esta función debería declararse async por consistencia con el resto de la API, y nombra qué comunicaría de más o de menos.'
    required: true
    hints:
      - 'Un Future en la firma sugiere que la función cede el turno, y esta no lo hace.'
      - 'Una API mezclada obliga a recordar cuál es cuál.'
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
  - '¿Por qué marcar una función async no evita que un ciclo síncrono largo bloquee su isolate?'
  - 'En un archivo vacío, vuelve a escribir sumaDeCuadrados con su validación, sin mirar tu solución.'
  - 'Explica en voz alta qué operaciones ceden el turno y cuáles no.'
  - 'Toma una operación pesada de otro proyecto y clasifícala como espera o como cálculo.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m12_isolates.dart'
  testCommand: 'fvm dart test test/m12_isolates_test.dart --name m12-1'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm12-1'
---

Hay dos cosas muy distintas que se llaman «tarda»: esperar algo externo y calcular algo caro. Solo la primera se arregla con `async`.

## Dos tipos de lentitud

|               | Espera de E/S                  | Trabajo de CPU                    |
| ------------- | ------------------------------ | --------------------------------- |
| ejemplo       | leer un archivo, pedir una URL | recorrer cien millones de enteros |
| quién trabaja | el sistema operativo           | tu programa                       |
| cede el turno | sí, en el `await`              | **no**                            |

Durante una espera de E/S, tu isolate no está haciendo nada: el sistema avisará cuando haya datos. Durante un cálculo, tu isolate está ocupado, y nada más puede correr.

## El malentendido

```dart
Future<int> sumaDeCuadrados(int n) async {
  var total = 0;
  for (var i = 1; i <= n; i++) {
    total += i * i;
  }
  return total;
}
```

Marcarla `async` no cambia **nada** de su comportamiento. No hay ningún `await` dentro, así que nunca cede el turno. Lo único que cambió es la firma, que ahora miente: sugiere que la función es asíncrona cuando bloquea igual.

Por eso el ejercicio la deja síncrona a propósito.

## Un isolate, un hilo, un bucle de eventos

Cada isolate tiene su propia memoria y **un solo hilo**. El bucle de eventos toma tareas de una cola y las ejecuta de a una. Un `await` devuelve el control al bucle; un ciclo lo retiene hasta terminar.

Un temporizador programado para 100 ms no dispara a los 100 ms si el bucle está ocupado: dispara cuando el bucle queda libre.

## Intento · antes de mirar

Decide cuál de estas dos permite que un temporizador siga respondiendo, y por qué:

```dart
await File('datos.txt').readAsString();
for (var i = 0; i < 100000000; i++) { total += i; }
```

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m12_isolates_test.dart --name m12-1
```

Pega la salida del caso conocido y del negativo.

## Fuente · lee con una pregunta

Abre **Isolates** y busca _event loop_. Pregunta concreta: ¿qué dice sobre las operaciones que no ceden el turno? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende dejarla síncrona. Un `Future` en la firma es una promesa de que la función cede el turno, y esta no lo hace: la firma estaría mintiendo.

El argumento contrario es la consistencia: una API donde algunas operaciones son `Future` y otras no obliga a recordar cuál es cuál. Elige y nombra el costo. En la próxima lección el cálculo se muda de isolate.
