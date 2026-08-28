---
id: 'D10-L02'
trackId: 'dart'
moduleId: 'D10'
kind: 'taller'
order: 1
slug: 'secuencia-o-paralelo'
title: 'Dos esperas: en fila o a la vez'
summary: 'Compara await encadenados con Future.wait y descubre cuándo paralelizar es una mejora y cuándo es un bug.'
estimatedMinutes: 55
objectives:
  - 'Distinguir esperas secuenciales de esperas concurrentes.'
  - 'Usar Future.wait cuando las operaciones son independientes.'
  - 'Reconocer cuándo paralelizar rompe una dependencia real.'
prerequisites: ['D10-L01']
activities:
  - id: 'predecir-tiempos'
    kind: 'attempt'
    prompt: 'Sin ejecutar nada, calcula cuánto tarda esperar dos operaciones de 200 ms en secuencia y a la vez, y decide qué pasa si la segunda necesita el resultado de la primera.'
    required: true
    hints:
      - 'En secuencia los tiempos se suman; a la vez, manda la más lenta.'
      - 'Si hay dependencia real, paralelizar no es una optimización: es un error.'
  - id: 'resolver-m11-2'
    kind: 'evidence'
    prompt: 'Implementa enSecuencia y enParalelo. Ejecuta sus pruebas y pega la salida del test que comprueba que las dos arrancan antes de que termine la primera.'
    required: true
    hints:
      - 'Un await encadenado impide que la segunda empiece.'
      - 'Future.wait recibe una lista de Futures ya iniciados.'
  - id: 'sustentar-future-wait'
    kind: 'source'
    prompt: 'En Asynchronous programming, encuentra qué hace Future.wait y qué ocurre con el orden de los resultados y con los errores.'
    required: true
    sourceLabel: 'Asynchronous programming'
    hints:
      - 'Busca Future.wait en la página o en la referencia enlazada.'
      - 'Fíjate en qué pasa si uno de los futures falla.'
  - id: 'defender-paralelo'
    kind: 'judgment'
    prompt: 'Decide cuándo conviene Future.wait en tu propio código y nombra el riesgo de aplicarlo sin comprobar la independencia.'
    required: true
    hints:
      - 'Dos consultas independientes ganan tiempo; dos pasos de un flujo no.'
      - 'Future.wait falla apenas uno falla, y los demás siguen corriendo.'
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
  - '¿Cuándo Future.wait reduce tiempo y cuándo cambia incorrectamente la dependencia?'
  - 'En un archivo vacío, vuelve a escribir enSecuencia y enParalelo sin mirar tu solución.'
  - 'Explica en voz alta qué ocurre con el orden del resultado de Future.wait.'
  - 'Toma dos llamadas seguidas de otro proyecto y decide si podrían ir a la vez.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m11_asincronia.dart'
  testCommand: 'fvm dart test test/m11_asincronia_test.dart --name m11-2'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm11-2'
---

Dos `await` seguidos suman sus tiempos. A veces eso es correcto y a veces es dinero tirado.

## En secuencia

```dart
final primera = await pedirPerfil();
final segunda = await pedirAjustes();
```

`pedirAjustes` no **empieza** hasta que `pedirPerfil` termina. Con 200 ms cada una, son 400 ms.

Esto es lo correcto cuando la segunda necesita el resultado de la primera. Es lo incorrecto cuando no.

## A la vez

```dart
Future.wait(<Future<String>>[pedirPerfil(), pedirAjustes()]);
```

Fíjate en el detalle: los paréntesis de llamada están **dentro** de la lista. Las dos operaciones ya arrancaron cuando `Future.wait` las recibe; lo único que hace es esperar a que todas terminen. Con 200 ms cada una, son 200 ms.

## El orden del resultado

`Future.wait` devuelve los resultados en el orden de **la lista**, no en el de finalización. Si la primera tarda 20 ms y la segunda 1 ms, el resultado sigue siendo `[primera, segunda]`.

## Cuando uno falla

`Future.wait` falla apenas uno de los futures falla — y los demás **siguen corriendo**. Si esas operaciones tienen efectos, puedes terminar con una escritura hecha y otra no, sin que nadie lo haya decidido. `eagerError: false` cambia el momento del fallo, no ese problema.

Esto es lo que separa paralelizar consultas de lectura —seguro— de paralelizar escrituras —hay que pensarlo.

## Intento · antes de mirar

Completa antes de ejecutar:

| Escenario                        | Tiempo total |
| -------------------------------- | ------------ |
| dos de 200 ms en secuencia       | ?            |
| dos de 200 ms a la vez           | ?            |
| una de 200 y una de 50, a la vez | ?            |

Y responde: si la segunda operación necesita el id que devuelve la primera, ¿se puede paralelizar?

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m11_asincronia_test.dart --name m11-2
fvm dart test test/m11_asincronia_test.dart --name m11-3
```

Pega la salida del test que comprueba que las dos arrancan antes de que termine la primera. Ese test no mide tiempo —sería frágil— sino el **orden de arranque**, que es lo que de verdad distingue las dos versiones.

## Fuente · lee con una pregunta

Abre **Asynchronous programming** y busca `Future.wait`. Dos preguntas: ¿en qué orden llegan los resultados?, ¿qué ocurre si uno falla? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende cuándo usar `Future.wait`. La regla —solo con operaciones independientes— es fácil de decir y fácil de romper: dos consultas que hoy son independientes pueden dejar de serlo cuando alguien agregue un paso.

Nombra cómo dejarías escrito ese supuesto. En la próxima lección el `Future` deja de entregar un valor y empieza a entregar **muchos**.
