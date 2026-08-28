---
id: 'D05-L03'
trackId: 'dart'
moduleId: 'D05'
kind: 'taller'
order: 2
slug: 'una-politica-de-duplicados-explicita'
title: 'Indexar obliga a decidir qué pasa con los duplicados'
summary: 'Escribe una función genérica que indexa por clave y declara explícitamente qué hace cuando dos elementos chocan.'
estimatedMinutes: 60
objectives:
  - 'Escribir una función genérica con dos parámetros de tipo.'
  - 'Declarar una política de duplicados en vez de dejarla implícita.'
  - 'Justificar cuándo lanzar es mejor que sobrescribir en silencio.'
prerequisites: ['D05-L02']
activities:
  - id: 'predecir-choque'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, escribe la firma de una función que convierta Iterable<T> en Map<K, T> y decide qué debería ocurrir si dos elementos producen la misma clave.'
    required: true
    hints:
      - 'La firma necesita dos parámetros de tipo y una función que extraiga la clave.'
      - 'Hay tres políticas posibles: primero gana, último gana, o lanzar.'
  - id: 'resolver-m06-3'
    kind: 'evidence'
    prompt: 'Implementa indexarPor y ejecuta sus pruebas. Pega la salida del test que comprueba el rechazo de claves repetidas.'
    required: true
    hints:
      - 'El mapa tiene containsKey para detectar el choque antes de escribir.'
      - 'ArgumentError.value te deja nombrar el valor culpable.'
  - id: 'sustentar-genericos'
    kind: 'source'
    prompt: 'En Generics, encuentra cómo se declaran varios parámetros de tipo en una función y qué gana el llamador frente a usar Object.'
    required: true
    sourceLabel: 'Generics'
    hints:
      - 'Busca los ejemplos con dos letras de tipo.'
      - 'Fíjate en qué dice sobre seguridad de tipos.'
  - id: 'defender-politica'
    kind: 'judgment'
    prompt: 'Elige entre lanzar, conservar el primero o conservar el último ante una clave repetida, y nombra el error que se vuelve invisible con cada alternativa.'
    required: true
    hints:
      - 'Sobrescribir en silencio pierde un elemento sin dejar rastro.'
      - 'Conservar el último puede ser exactamente lo que quieres si el origen viene ordenado por fecha.'
docRefs:
  - label: 'Generics'
    url: 'https://dart.dev/language/generics'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Collections'
    url: 'https://dart.dev/language/collections'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué decisión debe documentar una función que indexa elementos con claves repetidas?'
  - 'En un archivo vacío, vuelve a escribir indexarPor con su política de duplicados, sin mirar tu solución.'
  - 'Explica en voz alta qué gana el llamador cuando la función es genérica en vez de trabajar con Object.'
  - 'Escribe una variante de indexarPor que conserve el último y decide en qué caso la usarías.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m06_colecciones.dart'
  testCommand: 'fvm dart test test/m06_colecciones_test.dart --name m06-3'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm06-3'
---

Esta función es corta y contiene una decisión de diseño que la mayoría de las implementaciones toma sin darse cuenta.

## La firma primero

```dart
Map<K, T> indexarPor<T, K>(Iterable<T> elementos, K Function(T) clave)
```

Dos parámetros de tipo: `T` es lo que hay en la colección, `K` es lo que produce la función de clave. El compilador los conecta, así que quien la llame con `List<Usuario>` y una función que devuelve `String` recibe un `Map<String, Usuario>` sin escribir un solo `as`.

Ese `K Function(T)` es la misma forma que aprendiste a leer en D04-L01.

## El caso que casi nadie escribe

¿Qué pasa si dos elementos producen la misma clave? Hay tres respuestas, y la peor es no elegir:

| Política     | Qué ocurre                           | Qué se pierde                     |
| ------------ | ------------------------------------ | --------------------------------- |
| último gana  | `indice[k] = elemento` sin comprobar | un elemento desaparece sin rastro |
| primero gana | se ignora el segundo                 | igual, pero al revés              |
| lanzar       | `ArgumentError`                      | nada: el problema se ve           |

La implementación «natural» —asignar sin comprobar— es la de «último gana», y es peligrosa precisamente porque no se ve. Un mapa de 98 elementos donde esperabas 100 no falla en ningún lado: simplemente le faltan dos, y lo descubres semanas después.

Este contrato **lanza**. No porque lanzar sea siempre mejor, sino porque para una función de propósito general no hay forma de saber cuál de las otras dos querías, y adivinar en silencio es la única opción claramente mala.

## Intento · antes de mirar

Escribe la firma completa y decide tu política antes de ver la del contrato. Anota también qué mensaje daría tu error: ¿nombra la clave culpable?

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m06_colecciones_test.dart --name m06-3
```

Pega la salida del test de claves repetidas. Experimento: cambia tu implementación a «último gana», ejecuta y observa exactamente qué test lo detecta. Después vuelve al contrato.

## Fuente · lee con una pregunta

Abre **Generics** con una pregunta concreta: ¿cómo se declaran dos parámetros de tipo en una función y qué gana quien la llama frente a usar `Object`? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende la política del contrato. Después imagina un caso concreto donde «último gana» sería lo correcto —un histórico ordenado por fecha donde la última versión es la buena— y explica por qué ahí sí, y cómo lo dejarías escrito para que nadie tenga que adivinarlo.

En la próxima lección el mapa deja de guardar elementos y empieza a guardar cuentas.
