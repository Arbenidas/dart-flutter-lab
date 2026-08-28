---
id: 'D12-L02'
trackId: 'dart'
moduleId: 'D12'
kind: 'taller'
order: 1
slug: 'de-json-a-modelo-tipado'
title: 'JSON válido no significa dato válido'
summary: 'Convierte texto JSON en un modelo tipado y separa la validación de sintaxis, de forma y de dominio.'
estimatedMinutes: 60
objectives:
  - 'Decodificar JSON y comprobar la forma antes de construir un modelo.'
  - 'Distinguir un fallo de sintaxis, uno de forma y uno de dominio.'
  - 'Tratar un campo ausente de forma distinta a uno inválido.'
prerequisites: ['D12-L01']
activities:
  - id: 'clasificar-fallos-json'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, clasifica estos cuatro casos: texto que no es JSON, un arreglo donde se esperaba un objeto, un id numérico donde va texto, y un título vacío.'
    required: true
    hints:
      - 'Los tres primeros son problemas de estructura; el cuarto es de dominio.'
      - 'Un campo ausente puede ser válido si tiene un valor por defecto sensato.'
  - id: 'resolver-m13-2'
    kind: 'evidence'
    prompt: 'Implementa decodificarEntrada con sus tres clases de validación. Ejecuta sus pruebas y pega la salida del caso del título vacío.'
    required: true
    hints:
      - 'jsonDecode devuelve Object?: hay que comprobar el tipo antes de usarlo.'
      - 'Un título vacío es ArgumentError, no FormatException.'
  - id: 'sustentar-json'
    kind: 'source'
    prompt: 'En Using JSON, encuentra qué devuelve jsonDecode y qué recomienda la documentación sobre comprobar tipos.'
    required: true
    sourceLabel: 'Using JSON'
    hints:
      - 'Busca el tipo de retorno de jsonDecode.'
      - 'Fíjate en los ejemplos con cast o con comprobaciones.'
  - id: 'defender-tres-fallos'
    kind: 'judgment'
    prompt: 'Decide si los tres tipos de fallo deberían compartir una sola excepción o mantenerse separados, y nombra qué pierde quien los une.'
    required: true
    hints:
      - 'Un fallo de sintaxis y uno de dominio se corrigen de formas distintas.'
      - 'Tres tipos obligan a quien llama a atrapar tres cosas.'
docRefs:
  - label: 'Using JSON'
    url: 'https://dart.dev/libraries/serialization/json'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Error handling'
    url: 'https://dart.dev/language/error-handling'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué validaciones separan JSON sintácticamente válido de un objeto de dominio válido?'
  - 'En un archivo vacío, vuelve a escribir decodificarEntrada sin mirar tu solución.'
  - 'Explica en voz alta por qué jsonDecode devuelve Object? y no un mapa.'
  - 'Modela la decodificación de un usuario con tres campos y define qué falla en cada etapa.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m13_io_json_cli.dart'
  testCommand: 'fvm dart test test/m13_io_json_cli_test.dart --name m13-2'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm13-2'
---

`jsonDecode` te dice si el texto era JSON. No te dice nada sobre si ese JSON significa algo en tu dominio.

## Tres etapas, tres fallos

| Etapa    | Pregunta                                   | Fallo             |
| -------- | ------------------------------------------ | ----------------- |
| sintaxis | ¿es JSON?                                  | `FormatException` |
| forma    | ¿tiene los campos con los tipos correctos? | `FormatException` |
| dominio  | ¿los valores cumplen las reglas?           | `ArgumentError`   |

Las dos primeras son sobre la **estructura** del mensaje; la tercera es sobre tu negocio. `{"id":"e1","titulo":"   "}` es JSON impecable, con la forma correcta, y un título vacío que tu dominio no acepta.

## `jsonDecode` devuelve `Object?`

```dart
final Object? decodificado = jsonDecode(textoJson);

if (decodificado is! Map<String, Object?>) {
  throw const FormatException('Se esperaba un objeto JSON en la raíz');
}
```

No devuelve un mapa: devuelve `Object?`, porque el JSON de raíz puede ser un objeto, un arreglo, un número o `null`. Cada acceso requiere comprobar antes.

La tentación es `jsonDecode(texto) as Map<String, dynamic>`. Funciona y convierte una respuesta inesperada en un `TypeError` sin contexto, en lugar de un mensaje que diga qué esperabas.

## Ausente no es inválido

```dart
final etiquetas = decodificado['etiquetas'] ?? <Object?>[];
```

Un campo ausente puede ser perfectamente válido si hay un valor por defecto con sentido. Un campo presente con el tipo equivocado, no. Esa distinción —la de D02, otra vez— evita rechazar mensajes legítimos de una versión anterior de la API.

## Intento · antes de mirar

Clasifica los cuatro casos y anota qué excepción esperas de cada uno:

- `{no es json`
- `[1, 2]`
- `{"id": 1, "titulo": "x"}`
- `{"id": "e1", "titulo": "   "}`

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m13_io_json_cli_test.dart --name m13-2
fvm dart test test/m13_io_json_cli_test.dart --name m13-3
```

Pega la salida del caso del título vacío. Ese test comprueba `throwsArgumentError`, no `throwsFormatException`: si tu implementación mezcla las dos clases de fallo, ahí se ve.

## Fuente · lee con una pregunta

Abre **Using JSON** con una pregunta concreta: ¿qué devuelve `jsonDecode` y qué recomienda hacer con ese valor? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende mantener separados los fallos de forma y los de dominio. Un fallo de forma se corrige cambiando el emisor; uno de dominio, cambiando el dato. Quien recibe el error necesita saber cuál es.

El costo: quien llame tiene que atrapar dos tipos. Nombra tu postura. En la próxima lección los datos llegan por la línea de comandos.
