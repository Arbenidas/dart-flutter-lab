---
id: 'D06-L03'
trackId: 'dart'
moduleId: 'D06'
kind: 'taller'
order: 2
slug: 'constructor-factory-que-valida'
title: 'Un factory puede decidir antes de construir'
summary: 'Convierte una fracción en un porcentaje con un constructor que valida, redondea y elige qué devolver.'
estimatedMinutes: 50
objectives:
  - 'Distinguir un constructor generativo de uno factory.'
  - 'Validar y transformar una entrada antes de construir el objeto.'
  - 'Justificar cuándo un factory es mejor que una función suelta.'
prerequisites: ['D06-L02']
activities:
  - id: 'predecir-redondeo'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, predice qué Porcentaje produce una fracción de 0.333 y otra de 0.335, y qué debería ocurrir con 1.1 y con NaN.'
    required: true
    hints:
      - 'Redondear al entero más cercano no es lo mismo que truncar.'
      - 'NaN no es menor ni mayor que nada: hay que preguntarlo aparte.'
  - id: 'resolver-m07-3'
    kind: 'evidence'
    prompt: 'Implementa Porcentaje.desdeFraccion como factory y ejecuta sus pruebas. Pega la salida del caso de 0.335.'
    required: true
    hints:
      - 'El método round de un double redondea al entero más cercano.'
      - 'isNaN es la única forma fiable de detectar un NaN.'
  - id: 'sustentar-factory'
    kind: 'source'
    prompt: 'En Constructors, encuentra qué puede hacer un constructor factory que uno generativo no puede.'
    required: true
    sourceLabel: 'Constructors'
    hints:
      - 'Busca el encabezado de factory constructors.'
      - 'Fíjate si menciona devolver una instancia existente.'
  - id: 'defender-factory'
    kind: 'judgment'
    prompt: 'Decide entre un factory y una función suelta porcentajeDesdeFraccion, y nombra qué gana cada opción en descubribilidad y en pruebas.'
    required: true
    hints:
      - 'Un factory aparece junto al tipo al autocompletar.'
      - 'Una función suelta se puede sustituir más fácilmente en una prueba.'
docRefs:
  - label: 'Constructors'
    url: 'https://dart.dev/language/constructors'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Classes'
    url: 'https://dart.dev/language/classes'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Cuándo elegirías un constructor factory en lugar de uno generativo?'
  - 'En un archivo vacío, vuelve a escribir Porcentaje.desdeFraccion sin mirar tu solución.'
  - 'Explica en voz alta por qué NaN necesita una comprobación propia.'
  - 'Escribe un factory que construya un Porcentaje desde un texto y decide qué hace con una entrada inválida.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m07_clases.dart'
  testCommand: 'fvm dart test test/m07_clases_test.dart --name m07-3'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm07-3'
---

Un constructor generativo siempre crea un objeto nuevo y siempre el de su propia clase. Un `factory` no tiene esa obligación, y eso le abre tres posibilidades.

## Qué puede hacer un factory

1. **Transformar la entrada** antes de construir.
2. **Devolver una instancia existente** en vez de crear otra —así funcionan las cachés de objetos.
3. **Devolver un subtipo** según el argumento.

Aquí usamos la primera:

```dart
factory Porcentaje.desdeFraccion(double fraccion) {
  if (fraccion.isNaN || fraccion < 0 || fraccion > 1) {
    throw RangeError.value(fraccion, 'fraccion', 'Debe estar entre 0 y 1');
  }
  return Porcentaje((fraccion * 100).round());
}
```

Un constructor generativo no podría hacerlo: sus inicializadores corren antes del cuerpo y no puede decidir qué devolver.

## Dos detalles que muerden

**`NaN` no compara.** `double.nan < 0` es `false` y `double.nan > 1` también. Un `NaN` pasaría las dos comprobaciones de rango sin problema. Por eso `isNaN` va primero y aparte: no es paranoia, es que las comparaciones no sirven para detectarlo.

**Redondear no es truncar.** `(0.335 * 100).round()` da 34; `.toInt()` daría 33. Cuál corresponde es una decisión del dominio, y este contrato eligió redondear. Lo importante es que esté escrito en algún lado que no sea la implementación.

## Intento · antes de mirar

Completa la tabla antes de tocar el archivo:

| Fracción | Porcentaje esperado |
| -------- | ------------------- |
| `0.5`    | ?                   |
| `0.333`  | ?                   |
| `0.335`  | ?                   |
| `1.1`    | ?                   |
| `NaN`    | ?                   |

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m07_clases_test.dart --name m07-3
```

Pega la salida del caso de `0.335`. Experimento: cambia `.round()` por `.toInt()` y observa exactamente qué test lo detecta.

## Fuente · lee con una pregunta

Abre **Constructors** y busca el encabezado de constructores `factory`. Pregunta concreta: ¿qué puede hacer que un generativo no puede? Anota las tres capacidades.

## Criterio · decide y acepta el costo

Defiende el `factory` frente a una función suelta `porcentajeDesdeFraccion(double)`.

El `factory` aparece al escribir `Porcentaje.` en el editor, lo cual es un argumento real: la gente encuentra lo que el autocompletado le ofrece. La función suelta se sustituye más fácil en una prueba y no ata la conversión al tipo.

Elige y nombra el costo. En la próxima lección la invariante deja de ser un número y pasa a ser una **relación entre dos datos**.
