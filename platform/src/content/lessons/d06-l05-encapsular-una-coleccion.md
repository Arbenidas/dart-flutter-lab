---
id: 'D06-L05'
trackId: 'dart'
moduleId: 'D06'
kind: 'taller'
order: 4
slug: 'encapsular-una-coleccion-mutable'
title: 'Exponer una lista es entregar el control'
summary: 'Guarda la colección en privado, expón una vista de solo lectura y comprueba que nadie puede corromperla desde fuera.'
estimatedMinutes: 50
objectives:
  - 'Encapsular una colección mutable detrás de una vista de solo lectura.'
  - 'Explicar por qué un campo final que contiene una List no vuelve inmutable la lista.'
  - 'Reconocer el fallo que solo aparece al ejecutar.'
prerequisites: ['D06-L04']
activities:
  - id: 'predecir-fuga'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, predice qué ocurre si una clase expone directamente su lista privada y alguien de afuera le hace add.'
    required: true
    hints:
      - 'final protege la referencia, no el objeto: eso ya lo viste en D01.'
      - 'Si la lista es la misma, quien la reciba puede saltarse todas tus validaciones.'
  - id: 'resolver-m07-5'
    kind: 'evidence'
    prompt: 'Implementa Bitacora con su vista de solo lectura y su validación al agregar. Ejecuta sus pruebas y pega la salida del test que intenta modificar la lista expuesta.'
    required: true
    hints:
      - 'List.unmodifiable devuelve una vista que lanza al mutar.'
      - 'La validación de agregar es tuya; la protección de la lista es del tipo.'
  - id: 'sustentar-unmodifiable'
    kind: 'source'
    prompt: 'En Collections o en la referencia de Iterable, encuentra cómo se obtiene una vista no modificable de una lista y qué ocurre al intentar mutarla.'
    required: true
    sourceLabel: 'Collections'
    hints:
      - 'Busca unmodifiable en la página.'
      - 'Anota qué excepción se lanza.'
  - id: 'defender-copia-o-vista'
    kind: 'judgment'
    prompt: 'Decide entre devolver una vista no modificable y devolver una copia nueva en cada llamada, y nombra el costo de cada opción.'
    required: true
    hints:
      - 'Una vista refleja los cambios posteriores de la lista interna.'
      - 'Una copia es una fotografía estable y cuesta memoria en cada llamada.'
docRefs:
  - label: 'Collections'
    url: 'https://dart.dev/language/collections'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Classes'
    url: 'https://dart.dev/language/classes'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Por qué un campo final que contiene una List no vuelve inmutable la lista?'
  - 'En un archivo vacío, vuelve a escribir la clase Bitacora con su encapsulación, sin mirar tu solución.'
  - 'Explica en voz alta qué errores atrapa el analizador aquí y cuáles solo aparecen al ejecutar.'
  - 'Toma una clase tuya que exponga una lista y decide si debería devolver una vista, una copia o nada.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m07_clases.dart'
  testCommand: 'fvm dart test test/m07_clases_test.dart --name m07-5'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm07-5'
  revealReference: true
---

Toda la protección que construiste en este módulo se puede perder en una línea: exponer directamente la colección interna.

## La fuga

```dart
class Bitacora {
  final List<String> entradas = <String>[]; // parece protegido

  void agregar(String entrada) {
    if (entrada.trim().isEmpty) throw ArgumentError('vacía');
    entradas.add(entrada.trim());
  }
}
```

`entradas` es `final`. Y sin embargo:

```dart
bitacora.entradas.add('   '); // se salta la validación entera
bitacora.entradas.clear();    // adiós a todo
```

`final` protege la **referencia**, no el objeto. Es exactamente lo que viste en D01-L04, ahora con consecuencias: el método `agregar` valida y nadie está obligado a usarlo.

## La vista de solo lectura

```dart
class Bitacora {
  // ignore: unused_field
  final List<String> _entradas = <String>[];

  List<String> get entradas => List<String>.unmodifiable(_entradas);

  void agregar(String entrada) {
    final normalizada = entrada.trim();
    if (normalizada.isEmpty) {
      throw ArgumentError.value(entrada, 'entrada', 'No puede estar vacía');
    }
    _entradas.add(normalizada);
  }
}
```

Dos cambios: el campo pasa a privado con guion bajo, y el getter devuelve una vista que lanza al mutar. Ahora la única puerta de entrada es `agregar`, y esa puerta valida.

## El fallo que el analizador no ve

```dart
bitacora.entradas.add('colada');
```

Esto **compila**. El tipo estático es `List<String>` y `List<String>` tiene `add`. Solo al ejecutar aparece:

```text
Unsupported operation: Cannot add to an unmodifiable list
```

Es el mismo patrón de D01-L05 con la lista `const`, y por eso el ejercicio incluye una prueba que lo comprueba: el análisis estático no lo atrapa, así que el contrato tiene que fijarlo un test.

## Intento · antes de mirar

Predice el resultado de estas tres líneas sobre la versión con el campo público, indicando si fallan al analizar, al ejecutar, o funcionan:

```dart
bitacora.entradas = <String>[];
bitacora.entradas.add('   ');
bitacora.entradas.clear();
```

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m07_clases_test.dart --name m07-5
```

Pega la salida del test que intenta modificar la lista expuesta. Después haz el experimento completo: devuelve `_entradas` directamente, ejecuta `fvm dart analyze` —verás que no se queja— y luego los tests.

## Fuente · lee con una pregunta

Abre **Collections** y busca `unmodifiable`. Pregunta concreta: ¿qué devuelve y qué ocurre al intentar mutarla? Anota la excepción exacta.

## Criterio · decide y acepta el costo

Defiende la vista frente a devolver una copia con `List.of(_entradas)`.

La vista es barata y **refleja los cambios posteriores**: quien la guarde verá aparecer entradas nuevas, lo cual puede sorprender a la mitad de un recorrido. La copia es una fotografía estable y cuesta memoria en cada llamada.

Elige y nombra el costo. Cierra el módulo:

```bash
fvm dart analyze
```

En D07 las clases dejan de proteger datos y empiezan a **depender unas de otras** — y ahí aparece la pregunta de qué debería ser sustituible.
