---
id: 'D09-L03'
trackId: 'dart'
moduleId: 'D09'
kind: 'taller'
order: 2
slug: 'finally-y-rethrow'
title: 'finally corre siempre; rethrow conserva la pila'
summary: 'Comprueba el orden real de try, catch y finally, y descubre por qué relanzar con throw pierde información.'
estimatedMinutes: 50
objectives:
  - 'Predecir el orden de ejecución de try, catch y finally.'
  - 'Usar rethrow para conservar el error y su stack trace.'
  - 'Explicar por qué finally es donde se liberan los recursos.'
prerequisites: ['D09-L02']
activities:
  - id: 'predecir-orden'
    kind: 'attempt'
    prompt: 'Sin ejecutar nada, escribe el orden de las anotaciones en los dos caminos: cuando la acción devuelve un valor y cuando lanza.'
    required: true
    hints:
      - 'finally corre en los dos caminos.'
      - 'La anotación de éxito no debería aparecer cuando hubo un fallo.'
  - id: 'resolver-m10-3'
    kind: 'evidence'
    prompt: 'Implementa conRegistro con try, catch, finally y rethrow. Ejecuta sus pruebas y pega la salida del caso con fallo.'
    required: true
    hints:
      - 'rethrow solo se puede usar dentro de un catch.'
      - 'El error debe seguir subiendo con su tipo original.'
  - id: 'sustentar-finally'
    kind: 'source'
    prompt: 'En Error handling, encuentra qué garantiza finally y qué diferencia hay entre rethrow y volver a lanzar el error.'
    required: true
    sourceLabel: 'Error handling'
    hints:
      - 'Busca el encabezado de finally.'
      - 'Fíjate en si menciona el stack trace.'
  - id: 'defender-registro'
    kind: 'judgment'
    prompt: 'Decide si conviene registrar el fallo en esta capa o dejar que lo haga quien esté más arriba, y nombra el riesgo de cada opción.'
    required: true
    hints:
      - 'Registrar en cada capa produce el mismo error repetido cinco veces.'
      - 'No registrar en ninguna deja el fallo sin rastro si alguien lo traga.'
docRefs:
  - label: 'Error handling'
    url: 'https://dart.dev/language/error-handling'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Functions'
    url: 'https://dart.dev/language/functions'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Cuándo usarías on, catch, finally y rethrow?'
  - 'En un archivo vacío, vuelve a escribir conRegistro con sus tres bloques, sin mirar tu solución.'
  - 'Explica en voz alta qué pierde relanzar con throw en vez de rethrow.'
  - 'Envuelve una operación tuya que abra un recurso y comprueba que se libera también cuando falla.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m10_errores.dart'
  testCommand: 'fvm dart test test/m10_errores_test.dart --name m10-3'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm10-3'
---

`finally` se explica con la frase «corre siempre», y esa frase esconde el detalle que importa: corre **también** cuando el error va subiendo.

## El orden real

```dart
T conRegistro<T>(List<String> bitacora, T Function() accion) {
  bitacora.add('inicio');
  try {
    final resultado = accion();
    bitacora.add('exito');
    return resultado;
  } catch (_) {
    bitacora.add('fallo');
    rethrow;
  } finally {
    bitacora.add('cierre');
  }
}
```

Dos caminos:

| Camino | Anotaciones                 |
| ------ | --------------------------- |
| feliz  | `inicio`, `exito`, `cierre` |
| fallo  | `inicio`, `fallo`, `cierre` |

Fíjate en el camino feliz: el `return` ya se ejecutó y `cierre` aparece igual. `finally` corre **después** del `return` y antes de que el valor llegue a quien llamó. Por eso es el lugar de liberar recursos: no hay forma de salir del `try` sin pasar por ahí.

## `rethrow` no es `throw error`

```dart
} catch (error) {
  bitacora.add('fallo');
  rethrow;      // conserva el error Y su stack trace original
  // throw error; // conserva el error, pierde de dónde vino
}
```

`throw error` empieza una pila nueva desde esta línea. El resultado es un stack trace que apunta a tu `catch` en lugar de al sitio donde el problema ocurrió — justo la información que necesitabas.

`rethrow` solo se puede escribir dentro de un `catch`, precisamente porque necesita ese contexto.

## Atrapar para anotar, no para tragar

Este `catch` no resuelve nada: anota y deja seguir. Es un uso legítimo y frecuente. El antipatrón es el `catch` que anota y **no** relanza, dejando a quien llamó creyendo que todo salió bien.

## Intento · antes de mirar

Escribe el orden exacto de las anotaciones en los dos caminos. Después predice qué pasa si `accion` lanza y `finally` también lanza.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m10_errores_test.dart --name m10-3
```

Pega la salida del caso con fallo. Experimento: cambia `rethrow` por `throw error` y observa que los tests siguen pasando — el tipo se conserva. Lo que se pierde es el stack trace, y por eso este experimento se hace mirando la consola, no el informe.

## Fuente · lee con una pregunta

Abre **Error handling** con dos preguntas: ¿qué garantiza `finally`?, ¿qué diferencia hay entre `rethrow` y volver a lanzar? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende registrar el fallo en esta capa. Registrar en cada capa produce el mismo error cinco veces en el log, con cinco stack traces, y encontrar el original se vuelve trabajo. No registrar en ninguna deja el fallo sin rastro si alguien lo traga más arriba.

La convención habitual —registrar donde se **decide** qué hacer, no donde se pasa de largo— es una postura defendible. Elige la tuya. En la próxima lección un dato malo deja de detener el proceso.
