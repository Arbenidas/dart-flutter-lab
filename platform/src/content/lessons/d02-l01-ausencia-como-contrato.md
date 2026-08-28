---
id: 'D02-L01'
trackId: 'dart'
moduleId: 'D02'
kind: 'taller'
order: 0
slug: 'null-safety-como-contrato'
title: 'Ausencia no significa incertidumbre'
summary: 'Separa String de String? y usa ?? para dar un valor alternativo, descubriendo qué casos NO cubre.'
estimatedMinutes: 55
objectives:
  - 'Explicar qué garantiza un tipo no nulable que su versión nulable no puede garantizar.'
  - 'Usar el operador ?? para proveer un valor alternativo ante null.'
  - 'Reconocer que un texto vacío no es null y necesita su propia comprobación.'
prerequisites: ['D01-L05']
activities:
  - id: 'predecir-saludar'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, escribe de memoria saludar(String? nombre) y predice qué devuelve con «Diego», con null y con la cadena vacía.'
    required: true
    hints:
      - '?? solo se dispara cuando el valor de la izquierda es null.'
      - 'Una cadena vacía es un String perfectamente válido.'
  - id: 'resolver-m03-1'
    kind: 'evidence'
    prompt: 'Implementa saludar en lib/m03_null_safety.dart, ejecuta sus pruebas y pega la salida del caso de la cadena vacía.'
    required: true
    hints:
      - 'Necesitas dos comprobaciones distintas, no una.'
      - 'isEmpty responde una pregunta que ?? no responde.'
  - id: 'sustentar-null-safety'
    kind: 'source'
    prompt: 'En Understanding null safety, encuentra qué diferencia a String de String? para el compilador y registra el encabezado exacto.'
    required: true
    sourceLabel: 'Understanding null safety'
    hints:
      - 'Busca la sección que habla de non-nullable types.'
      - 'Anota una frase, no un párrafo.'
  - id: 'defender-vacio'
    kind: 'judgment'
    prompt: 'Decide si tratar la cadena vacía como ausencia es responsabilidad de saludar o de quien la llama, y nombra el costo de cada opción.'
    required: true
    hints:
      - 'Un formulario suele enviar «» en vez de null cuando el usuario no escribe nada.'
      - 'Meter la regla dentro de la función la vuelve menos reutilizable.'
docRefs:
  - label: 'Understanding null safety'
    url: 'https://dart.dev/null-safety/understanding-null-safety'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Operators'
    url: 'https://dart.dev/language/operators'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué garantía ofrece String que String? no puede ofrecer?'
  - 'En un archivo vacío, vuelve a escribir saludar sin mirar tu solución.'
  - 'Explica en voz alta por qué ?? no se dispara con una cadena vacía.'
  - 'Escribe una función que normalice un nombre: recorta espacios, trata «» como ausente y devuelve un valor por defecto.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m03_null_safety.dart'
  testCommand: 'fvm dart test test/m03_null_safety_test.dart --name m03-1'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm03-1'
---

El sistema de tipos de Dart divide el mundo en dos: los tipos que pueden ser `null` y los que no pueden serlo jamás. El compilador te obliga a demostrar cuál es cuál. No es burocracia: es la razón por la que una app bien tipada casi no lanza `NoSuchMethodError` en producción.

## Dos tipos, dos promesas

```dart
String seguro = 'Dart';   // nunca es null
String? quizas = null;    // puede serlo
```

Sobre `seguro` puedes llamar `.length` sin más trámite. Sobre `quizas` no: el analizador te lo impide hasta que demuestres que hay un valor. Esa exigencia es el producto que compras al declarar el tipo.

## `??` responde una sola pregunta

El operador si-null devuelve la izquierda salvo que sea `null`:

```dart
final nombre = entrada ?? 'desconocido';
```

Y ahí está la trampa de esta lección: **una cadena vacía no es null**. `'' ?? 'desconocido'` devuelve `''`, porque `''` es un `String` perfectamente válido. Los formularios web mandan `''` mucho más a menudo que `null`.

«Ausente» y «vacío» son dos conceptos distintos. Si tu dominio los trata igual, tienes que escribirlo tú:

```dart
if (nombre == null || nombre.isEmpty) { ... }
```

## Intento · antes de mirar

Escribe tu versión de `saludar` de memoria y predice las tres salidas: `'Diego'`, `null` y `''`. Si tu predicción para `''` es `'Hola, '`, ya descubriste el punto de la lección antes de ejecutar nada.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m03_null_safety_test.dart --name m03-1
```

Pega la salida del caso de la cadena vacía. Es el que separa una solución que compila de una que cumple el contrato.

## Fuente · lee con una pregunta

Abre **Understanding null safety** con una pregunta concreta: ¿qué puede hacer el compilador con un tipo no nulable que no puede hacer con uno nulable? Busca el encabezado sobre tipos no nulables y anótalo.

## Criterio · decide y acepta el costo

¿Debe `saludar` tratar `''` como ausencia, o debería recibir ya el dato limpio? Meter la regla dentro la vuelve más segura y menos reutilizable: una función que saluda no debería opinar sobre qué considera vacío tu formulario. Defiende tu elección y nombra qué se pierde.

En la próxima lección la pregunta cambia: cómo llegar a una propiedad de algo que quizá no exista, en una sola expresión.
