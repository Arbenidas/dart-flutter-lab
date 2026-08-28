---
id: 'D08-L01'
trackId: 'dart'
moduleId: 'D08'
kind: 'taller'
order: 0
slug: 'modelado-moderno-en-dart'
title: 'Un enum puede llevar datos y responder preguntas'
summary: 'Reemplaza cadenas libres por un conjunto cerrado de estados que además sabe describirse.'
estimatedMinutes: 50
objectives:
  - 'Declarar un enum con campos y constructor const.'
  - 'Explicar qué gana el compilador con un tipo cerrado frente a un String.'
  - 'Consultar values para razonar sobre el conjunto completo.'
prerequisites: ['D07-L05']
activities:
  - id: 'predecir-estados'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, enumera los estados de una descarga y decide cuáles son finales. Anota qué pasaría si se representaran con cadenas libres.'
    required: true
    hints:
      - 'Un estado final es aquel del que no se sale.'
      - 'Con cadenas libres, un error de tipeo entra sin avisar hasta la ejecución.'
  - id: 'resolver-m09-1'
    kind: 'evidence'
    prompt: 'Completa EstadoDescarga con su etiqueta y su bandera esFinal. Ejecuta sus pruebas y pega la salida del test que cuenta los estados finales.'
    required: true
    hints:
      - 'Un enum puede declarar campos final y un constructor const.'
      - 'values te da el conjunto completo en orden de declaración.'
  - id: 'sustentar-enums'
    kind: 'source'
    prompt: 'En Classes, localiza la sección de enums mejorados y encuentra qué puede declarar un enum además de sus valores.'
    required: true
    sourceLabel: 'Classes'
    hints:
      - 'Busca enhanced enums.'
      - 'Fíjate en la exigencia de que el constructor sea const.'
  - id: 'defender-enum'
    kind: 'judgment'
    prompt: 'Decide si el estado debería viajar como enum o como String desde una API externa, y nombra dónde pondrías la conversión.'
    required: true
    hints:
      - 'Una API devuelve texto: alguien tiene que convertirlo y decidir qué hace con lo desconocido.'
      - 'Convertir en la frontera deja el resto del programa trabajando con el tipo cerrado.'
docRefs:
  - label: 'Classes'
    url: 'https://dart.dev/language/classes'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Branches'
    url: 'https://dart.dev/language/branches'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Cuándo basta un enum y cuándo cada variante necesita una clase propia?'
  - 'En un archivo vacío, vuelve a escribir EstadoDescarga con sus campos, sin mirar tu solución.'
  - 'Explica en voz alta qué gana el compilador cuando un tipo es cerrado.'
  - 'Modela los estados de un pedido y decide cuál es final y qué acción ofrece cada uno.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m09_modelado.dart'
  testCommand: 'fvm dart test test/m09_modelado_test.dart --name m09-1'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm09-1'
---

En D03-L02 viste que una switch expression sobre `String` obliga a un caso por defecto porque el compilador no puede probar que cubriste todo. La solución empieza aquí.

## Un conjunto cerrado

```dart
enum EstadoDescarga {
  pendiente('Pendiente', false),
  activa('En curso', false),
  completada('Lista', true),
  fallida('Fallo', true);

  const EstadoDescarga(this.etiqueta, this.esFinal);

  final String etiqueta;
  final bool esFinal;
}
```

Cuatro valores, y **solo** cuatro. `'Completada'` con mayúscula, `'complete'` en inglés o `'compltada'` con un dedazo no compilan. Con un `String` los tres entran y fallan en ejecución.

## Con datos y comportamiento

Los enums de Dart pueden declarar campos, constructor `const` —obligatoriamente `const`, porque los valores se construyen al compilar— y también métodos y getters.

Eso permite que el estado **sepa cosas sobre sí mismo** en vez de repartir esa información en `switch` por todo el programa:

```dart
if (estado.esFinal) { ... }         // en vez de
if (estado == completada || estado == fallida) { ... }
```

La segunda forma hay que actualizarla en cada sitio cuando aparezca un quinto estado final. La primera, en un solo lugar.

## `values` razona sobre el conjunto

```dart
EstadoDescarga.values.where((estado) => estado.esFinal).length; // 2
```

`values` da la lista completa en orden de declaración. Sirve para construir menús, validar entradas y —como en la prueba de este ejercicio— comprobar propiedades del conjunto entero.

## Intento · antes de mirar

Enumera los estados de una descarga, marca cuáles son finales y anota tres formas de escribir mal `'completada'` que un `String` aceptaría sin quejarse.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m09_modelado_test.dart --name m09-1
```

Pega la salida del test que cuenta los estados finales.

## Fuente · lee con una pregunta

Abre **Classes** y busca _enhanced enums_. Pregunta concreta: ¿qué puede declarar un enum además de sus valores, y por qué su constructor debe ser `const`? Anota el encabezado.

## Criterio · decide y acepta el costo

Una API externa devuelve `"completed"` como texto. Defiende dónde conviertes ese texto en `EstadoDescarga` y qué haces con un valor que no reconoces.

La respuesta habitual —convertir en la frontera, tratar lo desconocido como un fallo explícito— deja todo el resto del programa trabajando con el tipo cerrado. Nombra el costo: alguien tiene que mantener esa conversión al día cuando la API agregue un estado.

En la próxima lección el tipo deja de ser fijo y pasa a ser un **parámetro**.
