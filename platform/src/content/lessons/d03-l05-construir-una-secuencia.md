---
id: 'D03-L05'
trackId: 'dart'
moduleId: 'D03'
kind: 'taller'
order: 4
slug: 'construir-una-secuencia-con-un-ciclo'
title: 'Validar la entrada antes de construir la salida'
summary: 'Construye Fibonacci con un ciclo, rechaza el argumento imposible y comprueba los casos degenerados antes que el general.'
estimatedMinutes: 50
objectives:
  - 'Validar un argumento al principio de la función en vez de a mitad del cálculo.'
  - 'Construir una lista acumulando resultados en un ciclo.'
  - 'Comprobar los casos degenerados de una secuencia antes que el caso general.'
prerequisites: ['D03-L04']
activities:
  - id: 'predecir-fibonacci'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, escribe qué devuelve fibonacci con 0, 1, 2 y 5, y qué debería ocurrir con -1.'
    required: true
    hints:
      - 'Los casos 0 y 1 son los que rompen las implementaciones apuradas.'
      - 'Un número negativo de términos no es un caso del cálculo: es una entrada inválida.'
  - id: 'resolver-m04-5'
    kind: 'evidence'
    prompt: 'Implementa fibonacci validando n mayor o igual que cero y usando un for. Ejecuta sus pruebas y pega la salida de los casos 0 y 1.'
    required: true
    hints:
      - 'Valida antes de construir nada.'
      - 'Los dos primeros términos son un caso aparte del ciclo general.'
  - id: 'sustentar-loops'
    kind: 'source'
    prompt: 'En Loops, localiza la forma de for con contador y compárala con for-in; anota cuándo la documentación sugiere cada una.'
    required: true
    sourceLabel: 'Loops'
    hints:
      - 'Busca el encabezado de for loops.'
      - 'Fíjate si la página distingue recorrer una colección de repetir n veces.'
  - id: 'defender-validacion'
    kind: 'judgment'
    prompt: 'Decide si fibonacci debe lanzar con n negativo o devolver una lista vacía, y nombra qué información se pierde con la alternativa.'
    required: true
    hints:
      - 'Una lista vacía es indistinguible del resultado legítimo de fibonacci con cero.'
      - 'Lanzar obliga a quien llama a decidir qué hacer con un dato imposible.'
docRefs:
  - label: 'Loops'
    url: 'https://dart.dev/language/loops'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Branches'
    url: 'https://dart.dev/language/branches'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Por qué los casos 0 y 1 se tratan aparte del ciclo general en Fibonacci?'
  - 'En un archivo vacío, vuelve a escribir fibonacci sin mirar tu solución.'
  - 'Explica en voz alta por qué validar al principio es mejor que comprobar a mitad del cálculo.'
  - 'Construye la secuencia de los primeros n números primos y decide dónde va la validación y dónde el caso degenerado.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m04_control.dart'
  testCommand: 'fvm dart test test/m04_control_test.dart --name m04-5'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm04-5'
  revealReference: true
---

Una función que construye una secuencia tiene tres partes bien separadas: validar la entrada, resolver los casos degenerados y correr el ciclo general. Mezclarlas es lo que produce implementaciones que fallan solo con `0` y con `1`.

## Validar primero

```dart
if (n < 0) {
  throw RangeError.value(n, 'n', 'debe ser mayor o igual que cero');
}
```

La validación va **antes** de reservar nada. Un `throw` a mitad del ciclo deja trabajo hecho a medias y un mensaje que no dice cuál fue la entrada. Al principio, la función tiene una sola forma de fallar y la nombra con precisión.

## Los casos degenerados no son el ciclo

```text
fibonacci(0) == []
fibonacci(1) == [0]
fibonacci(5) == [0, 1, 1, 2, 3]
```

El ciclo general necesita **dos** términos anteriores para producir el siguiente. Con `n == 0` no hay ninguno; con `n == 1` hay uno solo. Esos dos casos no son excepciones molestas: son la base sobre la que el ciclo se apoya, y por eso se resuelven antes.

Cuando una implementación falla solo con los valores más chicos, casi siempre es esto.

## Nada de recursión todavía

La versión recursiva de Fibonacci es famosa y es una mala primera implementación: repite el mismo cálculo un número enorme de veces. Compararla con la iterativa es interesante, pero comparar rendimiento sin saber medir produce conclusiones inventadas. Eso llega en D14, cuando tengas un entorno controlado para medir.

## Intento · antes de mirar

Escribe la tabla completa antes de tocar el archivo: `0`, `1`, `2`, `5` y `-1`. Anota especialmente qué esperas de `-1`.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m04_control_test.dart --name m04-5
```

Pega la salida de los casos `0` y `1`. Si el resto pasa y esos dos fallan, ya sabes exactamente qué parte falta.

## Fuente · lee con una pregunta

Abre **Loops** y localiza el `for` con contador. Pregunta concreta: ¿cuándo sugiere la documentación un `for` con índice y cuándo un `for-in`? Anota el encabezado y una frase.

## Criterio · decide y acepta el costo

Defiende el `throw` frente a devolver `[]` con `n` negativo. El argumento fuerte no es «lanzar es más correcto»: es que `[]` **ya significa otra cosa** en este contrato —es el resultado legítimo de `fibonacci(0)`—, así que devolverlo ante un error vuelve indistinguibles dos situaciones distintas. Es el mismo problema del valor centinela que viste en D02-L03.

Cierra el módulo:

```bash
fvm dart analyze
```

En D04 las funciones dejan de ser algo que escribes y pasan a ser algo que **pasas**: valores que viajan como cualquier otro dato.
