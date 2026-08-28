---
id: 'D09-L01'
trackId: 'dart'
moduleId: 'D09'
kind: 'taller'
order: 0
slug: 'errores-excepciones-y-depuracion-sistematica'
title: 'Un fallo esperado se modela; un bug se deja explotar'
summary: 'Distingue Exception de Error y escribe una excepción de dominio que lleva el contexto que hace falta para corregir.'
estimatedMinutes: 50
objectives:
  - 'Distinguir un fallo esperado de un bug del programador.'
  - 'Declarar una excepción de dominio con el contexto necesario.'
  - 'Explicar por qué Exception y Error existen por separado en Dart.'
prerequisites: ['D08-L05']
activities:
  - id: 'clasificar-fallos'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, clasifica como fallo esperado o bug: un usuario escribe letras donde va un número, un índice fuera de rango, una red caída y una división por cero con un divisor calculado.'
    required: true
    hints:
      - 'Un fallo esperado depende de datos que no controlas.'
      - 'Un bug depende de código que sí controlas.'
  - id: 'resolver-m10-1'
    kind: 'evidence'
    prompt: 'Implementa el toString de DatoInvalido y ejecuta sus pruebas. Pega la salida del test que comprueba que es una Exception.'
    required: true
    hints:
      - 'El texto debe nombrar el campo para que sirva en un registro.'
      - 'Exception se atrapa; Error señala un bug y no se suele atrapar.'
  - id: 'sustentar-errores'
    kind: 'source'
    prompt: 'En Error handling, encuentra qué distingue a Exception de Error y qué recomienda la documentación sobre atrapar cada uno.'
    required: true
    sourceLabel: 'Error handling'
    hints:
      - 'Busca la parte que compara los dos tipos.'
      - 'Anota el encabezado y la recomendación.'
  - id: 'defender-contexto'
    kind: 'judgment'
    prompt: 'Decide qué contexto debe llevar una excepción de dominio y qué no debería llevar nunca, y nombra el riesgo de cada exceso.'
    required: true
    hints:
      - 'Sin contexto, el error obliga a reproducir el problema para entenderlo.'
      - 'Con demasiado contexto, un registro puede terminar guardando datos personales.'
docRefs:
  - label: 'Error handling'
    url: 'https://dart.dev/language/error-handling'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Classes'
    url: 'https://dart.dev/language/classes'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué diferencia hay entre un fallo esperado, una excepción en una frontera y un bug?'
  - 'En un archivo vacío, vuelve a escribir DatoInvalido con su toString, sin mirar tu solución.'
  - 'Explica en voz alta por qué Dart separa Exception de Error.'
  - 'Escribe la excepción de dominio de una función tuya y decide qué contexto lleva.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m10_errores.dart'
  testCommand: 'fvm dart test test/m10_errores_test.dart --name m10-1'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm10-1'
---

Antes de cualquier `try`, hay una clasificación que decide todo lo demás.

## Dos categorías

|                | Fallo esperado                               | Bug                           |
| -------------- | -------------------------------------------- | ----------------------------- |
| de qué depende | datos que no controlas                       | código que sí controlas       |
| ejemplo        | el usuario escribe letras donde va un número | un índice fuera de rango      |
| qué hacer      | modelarlo y tratarlo                         | dejarlo explotar y arreglarlo |
| tipo en Dart   | `Exception`                                  | `Error`                       |

La razón de dejar explotar un bug es que **atraparlo lo esconde**. Un `catch` alrededor de un `RangeError` convierte un error reproducible en un comportamiento raro que aparece tres capas más arriba.

## La excepción de dominio

```dart
class DatoInvalido implements Exception {
  const DatoInvalido(this.campo, this.motivo);

  final String campo;
  final String motivo;

  @override
  String toString() => 'DatoInvalido($campo): $motivo';
}
```

Fíjate en `implements Exception`, no `extends`. `Exception` es una interfaz sin comportamiento: lo único que aporta es la clasificación.

Y fíjate en los dos campos. Un `throw Exception('dato inválido')` obliga a reproducir el problema para saber cuál dato y por qué. Estos dos campos son la diferencia entre un registro que sirve y uno que solo dice que algo pasó.

## `toString` no es decoración

Es lo que aparece en el registro, en la consola y en el informe de la prueba. Si no nombra el campo, el registro tampoco.

## Intento · antes de mirar

Clasifica los cuatro casos y justifica cada uno:

- un usuario escribe letras donde va un número
- un índice fuera de rango
- la red se cayó
- una división por cero con un divisor calculado

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m10_errores_test.dart --name m10-1
```

Pega la salida del test que comprueba que es una `Exception`. Ese test parece trivial y fija una decisión de diseño: si mañana alguien lo cambia a `extends Error`, todo el código que lo atrapa deja de funcionar.

## Fuente · lee con una pregunta

Abre **Error handling** con una pregunta concreta: ¿qué recomienda la documentación sobre atrapar `Error`? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende qué contexto lleva tu excepción. Poco contexto obliga a reproducir; mucho contexto termina guardando en el registro el dato personal que el usuario escribió.

La respuesta habitual: nombra el campo y la regla rota, no el valor completo. Nombra tu criterio y su costo. En la próxima lección la excepción de otro se convierte en la tuya.
