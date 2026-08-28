---
id: 'D03-L03'
trackId: 'dart'
moduleId: 'D03'
kind: 'taller'
order: 2
slug: 'records-y-destructuring'
title: 'Desarmar un valor en vez de interrogarlo'
summary: 'Recibe un record y usa patterns para descomponerlo, comprobando forma y contenido en la misma línea.'
estimatedMinutes: 55
objectives:
  - 'Leer y escribir el tipo de un record posicional.'
  - 'Desarmar un record con patterns dentro de una switch expression.'
  - 'Explicar por qué el orden de los casos decide el resultado al desestructurar.'
prerequisites: ['D03-L02']
activities:
  - id: 'predecir-punto'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, escribe qué devuelve describirPunto para (0, 0), (3, 0), (0, -2) y (2, 5), y en qué orden pondrías los casos.'
    required: true
    hints:
      - 'El origen cumple a la vez las dos condiciones de eje.'
      - 'El primer caso que coincide gana: eso decide dónde va (0, 0).'
  - id: 'resolver-m04-3'
    kind: 'evidence'
    prompt: 'Implementa describirPunto desarmando el record con patterns, ejecuta sus pruebas y pega la salida del caso del origen.'
    required: true
    hints:
      - 'Un caso puede escribirse como (0, 0) y otro como (_, 0).'
      - 'El guion bajo dentro del pattern significa: cualquier valor, no me importa cuál.'
  - id: 'sustentar-patterns'
    kind: 'source'
    prompt: 'En Patterns, encuentra cómo se desestructura un record y qué significa el guion bajo dentro de un pattern.'
    required: true
    sourceLabel: 'Patterns'
    hints:
      - 'Busca el encabezado sobre destructuring.'
      - 'Fíjate si distingue entre comparar y extraer.'
  - id: 'defender-record'
    kind: 'judgment'
    prompt: 'Decide si un punto del plano debería viajar como record (int, int) o como una clase Punto, y nombra el costo de cada opción.'
    required: true
    hints:
      - 'Un record no tiene nombre para sus campos posicionales ni métodos propios.'
      - 'Una clase cuesta más código y permite validar invariantes.'
docRefs:
  - label: 'Patterns'
    url: 'https://dart.dev/language/patterns'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Branches'
    url: 'https://dart.dev/language/branches'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué forma parte del tipo de un record posicional?'
  - 'En un archivo vacío, vuelve a escribir describirPunto sin mirar tu solución.'
  - 'Explica en voz alta por qué el orden de los patterns puede cambiar el resultado.'
  - 'Desarma un record de tres campos que represente una fecha y decide qué caso va primero.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m04_control.dart'
  testCommand: 'fvm dart test test/m04_control_test.dart --name m04-3'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm04-3'
---

Un pattern hace dos cosas a la vez: **comprueba** que el valor tenga cierta forma y **extrae** las partes que te interesan. Eso reemplaza a la secuencia habitual de comprobar, convertir y leer campos.

## Un record es una tupla con tipo

```dart
(int, int) punto = (3, 0);
```

El tipo del record es su **forma**: cuántos campos hay, en qué orden y de qué tipo. `(int, int)` y `(int, String)` son tipos distintos. No hace falta declarar una clase para devolver dos valores juntos.

## Desarmar en la rama

```dart
final descripcion = switch (punto) {
  (0, 0) => 'origen',
  (_, 0) => 'sobre el eje X',
  (0, _) => 'sobre el eje Y',
  _ => 'cuadrante libre',
};
```

Cada caso combina las dos operaciones. `(0, 0)` compara ambos campos contra cero. `(_, 0)` dice: _el primero no me importa, el segundo debe ser cero_. El guion bajo es un comodín que coincide con cualquier valor y no lo liga a ningún nombre.

## Por qué el origen va primero

`(0, 0)` cumple también `(_, 0)` y `(0, _)`. Si pusieras `(_, 0)` arriba, el origen se describiría como «sobre el eje X» y el caso `(0, 0)` nunca se alcanzaría.

Es la tercera vez en este curso que aparece la misma regla —después de `is` en D01 y de los rangos en D03-L01— y no es casualidad: **en toda estructura de ramas, lo más específico va primero**. Vale la pena escribirla en tu cuaderno una sola vez y reconocerla después.

## Intento · antes de mirar

Escribe los cuatro casos y **el orden** que les darías, con el motivo. Si tu orden pone `(0, 0)` en segundo lugar, predice también qué devolvería el origen.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m04_control_test.dart --name m04-3
```

Pega la salida del caso del origen. Prueba a propósito, una vez, con el orden equivocado: ver el test fallar por una razón que ya predijiste vale más que verlo pasar a la primera.

## Fuente · lee con una pregunta

Abre **Patterns** y busca la sección sobre desestructuración. Pregunta concreta: ¿qué significa el guion bajo dentro de un pattern y en qué se diferencia de un nombre de variable? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende el tipo de entrada: `(int, int)` o una clase `Punto`. El record es gratis de declarar y no tiene nombres para sus campos ni lugar donde validar; la clase cuesta código y puede garantizar invariantes y ofrecer métodos.

Para esta función, ¿cuál eliges y qué aceptas perder? En D06 vas a construir la alternativa con clases y podrás volver a esta decisión con más información.
