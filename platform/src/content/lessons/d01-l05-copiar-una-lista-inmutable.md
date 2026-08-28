---
id: 'D01-L05'
trackId: 'dart'
moduleId: 'D01'
kind: 'taller'
order: 4
slug: 'copiar-una-lista-inmutable'
title: 'Una lista const es inmutable de verdad'
summary: 'Descubre por qué modificar una constante compila pero explota, y aprende a copiar antes de cambiar.'
estimatedMinutes: 45
objectives:
  - 'Reconocer un error que el analizador no atrapa y solo aparece al ejecutar.'
  - 'Copiar una colección inmutable para producir una versión ampliada.'
  - 'Decidir cuándo devolver una copia y cuándo exponer la colección original.'
prerequisites: ['D01-L04']
activities:
  - id: 'predecir-add'
    kind: 'attempt'
    prompt: 'Sin ejecutar nada, predice qué ocurre al llamar diasHabiles.add(«sabado»): ¿lo detecta el analizador, falla al ejecutar o funciona?'
    required: true
    hints:
      - 'El tipo estático de diasHabiles sigue siendo List<String>.'
      - '¿Qué sabe el analizador sobre el objeto concreto detrás de esa referencia?'
  - id: 'resolver-m02-5'
    kind: 'evidence'
    prompt: 'Implementa semanaCompleta devolviendo una lista nueva con los cinco días hábiles más sábado y domingo, ejecuta sus pruebas y pega la salida.'
    required: true
    hints:
      - 'Necesitas construir una lista nueva, no modificar la constante.'
      - 'El operador de propagación ... copia los elementos de otra colección.'
  - id: 'sustentar-listas'
    kind: 'source'
    prompt: 'En Built-in types, localiza la sección de listas y encuentra cómo se construye una lista a partir de otra sin mutarla.'
    required: true
    sourceLabel: 'Built-in types'
    hints:
      - 'Busca spread operator dentro de la página.'
      - 'Registra el encabezado y un ejemplo mínimo propio.'
  - id: 'defender-copia'
    kind: 'judgment'
    prompt: 'Decide si semanaCompleta debería devolver una copia nueva en cada llamada o una constante compartida, y qué costo aceptas en cada caso.'
    required: true
    hints:
      - 'Una copia nueva protege a quien llama, pero se paga en memoria y tiempo.'
      - 'Una constante compartida es barata hasta que alguien intenta modificarla.'
docRefs:
  - label: 'Built-in types'
    url: 'https://dart.dev/language/built-in-types'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'The Dart type system'
    url: 'https://dart.dev/language/type-system'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Por qué diasHabiles.add(«sabado») compila pero falla al ejecutar?'
  - 'En un archivo vacío, vuelve a escribir semanaCompleta sin mirar tu solución.'
  - 'Explica en voz alta qué errores atrapa el analizador y cuáles solo aparecen al ejecutar.'
  - 'Escribe una función que reciba una lista y devuelva una versión ordenada sin modificar la original; comprueba que la entrada no cambió.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m02_tipos.dart'
  testCommand: 'fvm dart test test/m02_tipos_test.dart --name m02-5'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm02-5'
  revealReference: true
---

Esta lección cierra el módulo con el tipo de fallo más incómodo: el que el analizador **no** atrapa.

## Un error que compila

```dart
const List<String> diasHabiles = <String>['lunes', 'martes', 'miercoles', 'jueves', 'viernes'];

diasHabiles.add('sabado'); // compila sin avisos
```

El analizador ve una referencia de tipo `List<String>`, y `List<String>` tiene un método `add`. Todo cuadra estáticamente. Pero el objeto concreto detrás de esa referencia es una lista constante, y al ejecutar lanza:

```text
Unsupported operation: Cannot add to an unmodifiable list
```

Aquí se ve, en un caso mínimo, la distinción de la primera lección del módulo: el **tipo estático** permite la operación, el **objeto real** la rechaza. El análisis estático es una red muy útil y no atrapa todo.

## Copiar antes de cambiar

Para producir una versión ampliada hay que construir una lista nueva. El operador de propagación copia los elementos de otra colección dentro de un literal:

```dart
final ampliada = <String>[...original, 'nuevo'];
```

La original queda intacta. Ese es el patrón: **no muto, produzco**.

## Intento · antes de mirar

Escribe tu predicción para tres líneas, indicando en cada caso si falla al analizar, falla al ejecutar o funciona:

```dart
diasHabiles.add('sabado');
final copia = [...diasHabiles]; copia.add('sabado');
const otra = [...diasHabiles, 'sabado'];
```

## Evidencia · ejecuta y compara

Implementa `semanaCompleta` y ejecuta sus pruebas:

```bash
cd dart_lab
fvm dart test test/m02_tipos_test.dart --name m02-5
```

Después haz el experimento que la lección promete: agrega temporalmente `diasHabiles.add('sabado');` dentro de un archivo de prueba, ejecuta `fvm dart analyze` —verás que no se queja— y luego ejecútalo. Pega el mensaje exacto de la excepción y borra la línea.

## Fuente · lee con una pregunta

Abre **Built-in types**, sección de listas. Pregunta concreta: ¿cómo se construye una lista a partir de otra sin modificarla? Anota el encabezado del operador de propagación y escribe tu propio ejemplo de una línea.

## Criterio · decide y acepta el costo

`semanaCompleta` devuelve una lista nueva en cada llamada. Defiende esa decisión frente a la alternativa: devolver siempre la misma constante de siete días. Una protege a quien llama de mutaciones accidentales y cuesta una copia; la otra es gratis hasta que alguien intenta modificarla y descubre la excepción por su cuenta.

Cuando todos los tests del módulo pasen, cierra con la verificación completa:

```bash
fvm dart analyze
```

Ya tienes lenguaje para hablar de tipos, valores, exactitud y mutabilidad. En D02 el sistema de tipos empieza a hablar de algo que todavía no nombramos: la **ausencia** de un valor.
