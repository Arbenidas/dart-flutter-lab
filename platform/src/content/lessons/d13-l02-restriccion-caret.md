---
id: 'D13-L02'
trackId: 'dart'
moduleId: 'D13'
kind: 'taller'
order: 1
slug: 'restricciones-caret-y-compatibilidad'
title: 'La regla caret cambia antes y después de 1.0.0'
summary: 'Implementa la restricción caret y descubre por qué una versión 0.x se trata distinto de una estable.'
estimatedMinutes: 55
objectives:
  - 'Implementar la regla caret para versiones estables y 0.x.'
  - 'Explicar qué promete un cambio de versión mayor, menor y de parche.'
  - 'Elegir la versión más alta compatible de un conjunto.'
prerequisites: ['D13-L01']
activities:
  - id: 'predecir-caret'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, decide qué versiones satisfacen una restricción caret sobre 1.2.0 y cuáles sobre 0.14.0, y por qué la regla cambia.'
    required: true
    hints:
      - 'Antes de 1.0.0 la API todavía no prometió estabilidad.'
      - 'Una menor en 0.x puede romper compatibilidad; en 1.x no debería.'
  - id: 'resolver-m14-3'
    kind: 'evidence'
    prompt: 'Implementa satisfaceCaret y resolverMasAlta. Ejecuta sus pruebas y pega la salida del caso de la base 0.x.'
    required: true
    hints:
      - 'Una candidata anterior a la base nunca satisface.'
      - 'Para base 0.x, el límite superior es la siguiente menor.'
  - id: 'sustentar-caret'
    kind: 'source'
    prompt: 'En The pubspec file, encuentra cómo se declara una restricción caret y qué rango representa.'
    required: true
    sourceLabel: 'The pubspec file'
    hints:
      - 'Busca caret syntax en la página.'
      - 'Fíjate en el ejemplo con una versión 0.x.'
  - id: 'defender-restriccion'
    kind: 'judgment'
    prompt: 'Decide entre fijar una versión exacta y usar una restricción caret en un proyecto de aplicación, y nombra el riesgo de cada opción.'
    required: true
    hints:
      - 'Fijar exacto es reproducible y deja fuera correcciones de seguridad.'
      - 'El caret trae mejoras y también cambios que nadie revisó.'
docRefs:
  - label: 'The pubspec file'
    url: 'https://dart.dev/tools/pub/pubspec'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Creating packages'
    url: 'https://dart.dev/tools/pub/create-packages'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Cómo interpreta caret una versión estable y una versión 0.x en Dart?'
  - 'En un archivo vacío, vuelve a escribir satisfaceCaret con sus dos reglas, sin mirar tu solución.'
  - 'Explica en voz alta qué promete cada parte del número de versión.'
  - 'Revisa el pubspec de un proyecto tuyo y decide si alguna restricción debería ser más estricta.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m14_paquetes.dart'
  testCommand: 'fvm dart test test/m14_paquetes_test.dart --name m14-3'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm14-3'
---

`^1.2.0` en un pubspec es una promesa con letra chica, y la letra chica cambia según si el paquete llegó a 1.0.0.

## Qué promete cada número

| Cambia | Significa                                   |
| ------ | ------------------------------------------- |
| parche | corrección, sin cambios de API              |
| menor  | funcionalidad nueva, compatible hacia atrás |
| mayor  | cambio que rompe compatibilidad             |

Esa es toda la idea del versionado semántico: el número te dice si puedes actualizar sin leer el changelog.

## La regla caret

Para una base **estable** (`mayor >= 1`), el límite es la siguiente mayor:

```text
^1.2.0  ->  >=1.2.0 <2.0.0
```

`1.9.0` y `1.2.5` sirven; `2.0.0` no, y `1.1.9` tampoco —es anterior a lo que pediste.

Para una base **0.x**, el límite es la siguiente **menor**:

```text
^0.14.0  ->  >=0.14.0 <0.15.0
```

El motivo: antes de 1.0.0 la API todavía no prometió estabilidad, así que una menor puede romper. Dart trata `0.15.0` como si fuera una mayor nueva.

```dart
bool satisfaceCaret(Version base, Version candidata) {
  if (candidata < base) return false;
  if (base.mayor > 0) return candidata.mayor == base.mayor;
  return candidata.mayor == 0 && candidata.menor == base.menor;
}
```

## Resolver la más alta

```dart
Version? resolverMasAlta(Version base, Iterable<Version> disponibles) {
  final compatibles = disponibles.where((v) => satisfaceCaret(base, v)).toList()..sort();
  return compatibles.isEmpty ? null : compatibles.last;
}
```

Devuelve `null` cuando ninguna sirve — el tipo nulable de D02-L03 comunicando «puede no haber respuesta». Es, en miniatura, lo que hace `pub get`.

## Intento · antes de mirar

Completa antes de tocar el archivo:

| Restricción | ¿1.9.0? | ¿2.0.0? | ¿0.15.0? |
| ----------- | ------- | ------- | -------- |
| `^1.2.0`    | ?       | ?       | —        |
| `^0.14.0`   | —       | ?       | ?        |

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m14_paquetes_test.dart --name m14-3
fvm dart test test/m14_paquetes_test.dart --name m14-4
```

Pega la salida del caso de la base 0.x.

## Fuente · lee con una pregunta

Abre **The pubspec file** y busca la sintaxis caret. Pregunta concreta: ¿qué rango representa, y qué cambia con una base 0.x? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende usar caret en una aplicación. Fijar la versión exacta es reproducible y te deja fuera de las correcciones de seguridad hasta que alguien se acuerde de actualizar.

Y fíjate en que hay una tercera pieza: el `pubspec.lock` fija lo que se instaló de verdad, así que la restricción declara el **rango aceptable** y el lock la **versión concreta**. Nombra tu postura sobre las dos.

En la última lección del módulo, lo que se publica deja de ser una versión y pasa a ser una **superficie**.
