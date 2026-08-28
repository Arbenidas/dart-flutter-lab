---
id: 'D03-L01'
trackId: 'dart'
moduleId: 'D03'
kind: 'taller'
order: 0
slug: 'decisiones-ciclos-y-patterns'
title: 'El control de flujo hace visible tu lógica'
summary: 'Escribe la misma clasificación dos veces, con if encadenados y con una switch expression relacional, y compara qué se lee mejor.'
estimatedMinutes: 60
objectives:
  - 'Escribir una switch expression con patterns relacionales.'
  - 'Explicar por qué el orden de las ramas cambia el resultado.'
  - 'Comparar dos implementaciones correctas y defender una por legibilidad.'
prerequisites: ['D02-L05']
activities:
  - id: 'predecir-fronteras'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, escribe qué devuelve clasificarEdad en cada frontera: -1, 0, 12, 13, 17, 18, 64 y 65.'
    required: true
    hints:
      - 'Cada frontera tiene dos lados y los dos importan.'
      - 'Una edad negativa no es infancia: es una entrada inválida.'
  - id: 'resolver-m04-1'
    kind: 'evidence'
    prompt: 'Implementa clasificarEdad primero con if encadenados, ejecuta sus pruebas, y después reescríbela como switch expression relacional. Pega la salida de la segunda versión.'
    required: true
    hints:
      - 'Los patterns relacionales se escriben así: < 0 => ..., <= 12 => ...'
      - 'El primer caso que coincide gana: ordena de lo más específico a lo más general.'
  - id: 'sustentar-branches'
    kind: 'source'
    prompt: 'En Branches, encuentra qué distingue una switch expression de un switch statement y cómo se escriben los patterns relacionales.'
    required: true
    sourceLabel: 'Branches'
    hints:
      - 'Busca el encabezado de switch expressions.'
      - 'Fíjate si la página menciona la palabra case en cada forma.'
  - id: 'defender-version'
    kind: 'judgment'
    prompt: 'Elige cuál de tus dos versiones dejarías en un proyecto real y nombra qué pierde la que descartas.'
    required: true
    hints:
      - 'La versión con if permite poner un punto de interrupción por rama.'
      - 'La switch expression hace visible que todas las ramas producen un valor del mismo tipo.'
docRefs:
  - label: 'Branches'
    url: 'https://dart.dev/language/branches'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Patterns'
    url: 'https://dart.dev/language/patterns'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Por qué conviene probar ambos lados de cada frontera numérica?'
  - 'En un archivo vacío, vuelve a escribir clasificarEdad como switch expression sin mirar tu solución.'
  - 'Explica en voz alta qué diferencia hay entre un switch statement y una switch expression.'
  - 'Clasifica una temperatura en cinco rangos con patterns relacionales y define qué hacer con un valor imposible.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m04_control.dart'
  testCommand: 'fvm dart test test/m04_control_test.dart --name m04-1'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm04-1'
---

Dart 3 convirtió al `switch` en una herramienta de primera clase. Ya no es el `switch` con `break` de C: es una **expresión** que devuelve un valor y sabe desarmar objetos. Vas a usar esto todo el tiempo en Flutter para mapear estado a interfaz.

## Statement y expression no son lo mismo

```dart
// statement: ejecuta ramas, no devuelve nada
switch (edad) {
  case < 0:
    print('invalida');
  default:
    print('otra');
}

// expression: produce un valor
final etiqueta = switch (edad) {
  < 0 => 'invalida',
  <= 12 => 'infancia',
  _ => 'otra',
};
```

Dos diferencias visibles: la expresión **no escribe la palabra `case`**, y cada rama termina en `,`. Y una diferencia invisible que importa más: como toda expresión produce un valor, el compilador comprueba que todas las ramas devuelvan el mismo tipo, y que haya una rama para cada entrada posible.

## El orden es parte de la lógica

Los patterns relacionales comparan contra un valor: `< 0`, `<= 12`, `>= 65`. Y **gana el primero que coincide**:

```dart
final etiqueta = switch (edad) {
  <= 64 => 'adultez',   // atrapa también a los niños
  <= 12 => 'infancia',  // nunca se alcanza
  _ => 'vejez',
};
```

Es exactamente el mismo error que cometías con `is num` antes que `is int` en D01. La regla se repite: **de lo específico a lo general**.

## Intento · antes de mirar

Escribe la tabla de fronteras antes de tocar nada. No basta con `10` y `30`: los valores que rompen implementaciones son los bordes.

| Edad | Esperado |
| ---- | -------- |
| -1   | ?        |
| 0    | ?        |
| 12   | ?        |
| 13   | ?        |
| 17   | ?        |
| 18   | ?        |
| 64   | ?        |
| 65   | ?        |

## Evidencia · ejecuta y compara

Implementa primero con `if / else if` y ejecuta:

```bash
cd dart_lab
fvm dart test test/m04_control_test.dart --name m04-1
```

Cuando pase, **bórralo** y reescríbelo con una switch expression relacional. Vuelve a ejecutar y pega la salida de la segunda versión. Este ejercicio tiene además un test de estructura: comprueba que la versión final use la forma pedida, no solo que el resultado sea correcto.

## Fuente · lee con una pregunta

Abre **Branches** con dos preguntas: ¿qué distingue una switch expression de un switch statement?, y ¿cómo se escribe un pattern relacional? Anota el encabezado de cada respuesta.

## Criterio · decide y acepta el costo

Tienes dos versiones correctas del mismo comportamiento. Esa es la situación donde aparece el criterio. Defiende cuál dejarías: la cadena de `if` permite un punto de interrupción por rama y se lee sin saber sintaxis nueva; la switch expression hace visible que todas las ramas producen un valor y del mismo tipo.

Elige una y nombra qué pierdes con la otra. En la próxima lección los casos dejan de ser rangos numéricos y pasan a ser valores agrupados.
