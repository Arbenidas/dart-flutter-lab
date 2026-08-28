---
id: 'D04-L01'
trackId: 'dart'
moduleId: 'D04'
kind: 'taller'
order: 0
slug: 'funciones-parametros-y-closures'
title: 'La firma cuenta la historia antes que el cuerpo'
summary: 'Aprende a leer un tipo función y pasa una función como argumento de otra.'
estimatedMinutes: 45
objectives:
  - 'Leer en voz alta un tipo como int Function(int).'
  - 'Pasar una función como argumento y llamarla desde dentro.'
  - 'Explicar por qué en Flutter casi todo recibe funciones.'
prerequisites: ['D03-L05']
activities:
  - id: 'predecir-firma'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, escribe cómo leerías en voz alta int Function(int) y String Function(int, bool), y qué cuerpo tendría aplicar.'
    required: true
    hints:
      - 'Léelo de derecha a izquierda: qué recibe y qué devuelve.'
      - 'El cuerpo de aplicar es una sola línea.'
  - id: 'resolver-m05-1'
    kind: 'evidence'
    prompt: 'Implementa aplicar en lib/m05_funciones.dart, ejecuta sus pruebas y pega la salida.'
    required: true
    hints:
      - 'La función que recibes se llama igual que cualquier otra: con paréntesis.'
      - 'Lo importante no es el cuerpo, es haber leído la firma antes.'
  - id: 'sustentar-functions'
    kind: 'source'
    prompt: 'En Functions, encuentra cómo se declara un parámetro cuyo tipo es una función y registra el encabezado exacto.'
    required: true
    sourceLabel: 'Functions'
    hints:
      - 'Busca la sección sobre functions as parameters o first-class functions.'
      - 'Anota un ejemplo mínimo propio, no el de la página.'
  - id: 'defender-parametro'
    kind: 'judgment'
    prompt: 'Decide si aplicar aporta algo frente a llamar directamente a la transformación, y nombra en qué situación empieza a valer la pena.'
    required: true
    hints:
      - 'Pregúntate quién elige la transformación: quien escribe la función o quien la llama.'
      - 'Piensa en una lista de operaciones configurables.'
docRefs:
  - label: 'Functions'
    url: 'https://dart.dev/language/functions'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'The Dart type system'
    url: 'https://dart.dev/language/type-system'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Cómo se lee el tipo int Function(int)?'
  - 'En un archivo vacío, vuelve a escribir aplicar y una función que le pases, sin mirar tu solución.'
  - 'Explica en voz alta por qué onPressed y builder en Flutter reciben funciones.'
  - 'Escribe una función que reciba una lista y un predicado, y devuelva cuántos elementos lo cumplen.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m05_funciones.dart'
  testCommand: 'fvm dart test test/m05_funciones_test.dart --name m05-1'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm05-1'
---

En Dart las funciones son objetos. Se guardan en variables, se pasan como argumentos y se devuelven desde otras funciones. Flutter está construido sobre esto: `onPressed`, `builder`, `itemBuilder`, `setState` — todos reciben funciones.

## Leer un tipo función

```dart
int Function(int) transformacion;
```

Se lee: _«una función que recibe un `int` y devuelve un `int`»_. El tipo de retorno va primero, la palabra `Function` en el medio, los parámetros entre paréntesis.

```dart
String Function(int, bool)    // recibe un int y un bool, devuelve String
void Function()               // no recibe nada, no devuelve nada
```

Si sabes leer estos tres, ya puedes leer la mitad de la API de Flutter. Un `ValueChanged<String>` es `void Function(String)` con otro nombre.

## Pasarla y llamarla

```dart
int aplicar(int valor, int Function(int) transformacion) {
  return transformacion(valor);
}

aplicar(21, (n) => n * 2); // 42
```

La función recibida se llama como cualquier otra: con paréntesis. Lo nuevo no es el cuerpo —es una línea— sino **quién decide** qué hace la transformación: no quien escribió `aplicar`, sino quien la llama.

## Intento · antes de mirar

Escribe, antes de abrir nada:

1. Cómo lees en voz alta `int Function(int)` y `String Function(int, bool)`.
2. El cuerpo completo de `aplicar`.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m05_funciones_test.dart --name m05-1
```

Pega la salida. Este ejercicio pasa rápido: el objetivo no era el cuerpo, era haber leído la firma primero.

## Fuente · lee con una pregunta

Abre **Functions** y busca cómo se declara un parámetro cuyo tipo es una función. Anota el encabezado y escribe **tu propio** ejemplo mínimo, no el de la página.

## Criterio · decide y acepta el costo

`aplicar(21, (n) => n * 2)` es más largo que `21 * 2`. Entonces, ¿para qué sirve?

Defiende en qué situación empieza a valer la pena: cuando la transformación llega de otro lado, cuando hay que probar la misma estructura con varias operaciones, cuando el usuario la elige. Nombra también el costo: una capa más de indirección que hay que seguir al leer.

En la próxima lección el problema deja de ser el tipo del parámetro y pasa a ser **su nombre**.
