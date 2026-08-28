---
id: 'D09-L05'
trackId: 'dart'
moduleId: 'D09'
kind: 'taller'
order: 4
slug: 'un-mensaje-que-no-filtra-nada'
title: 'El mensaje que ve la persona no es el del log'
summary: 'Traduce cualquier error a un texto útil y seguro, sin filtrar rutas, consultas ni datos internos.'
estimatedMinutes: 45
objectives:
  - 'Convertir un error en un mensaje seguro para una persona.'
  - 'Explicar qué información nunca debe llegar a la pantalla.'
  - 'Usar un switch sobre tipos para cubrir lo conocido y lo desconocido.'
prerequisites: ['D09-L04']
activities:
  - id: 'reescribir-errores'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, reescribe estos mensajes para una persona: «FormatException at line 12», «SocketException: 111» y «null check operator on a null value».'
    required: true
    hints:
      - 'Un mensaje útil dice qué hacer, no qué falló por dentro.'
      - 'Si no hay nada que la persona pueda hacer, dilo y ofrece reintentar.'
  - id: 'resolver-m10-5'
    kind: 'evidence'
    prompt: 'Implementa mensajeParaUsuario con un switch sobre el tipo del error. Ejecuta sus pruebas y pega la salida del test que comprueba que no se filtra el motivo técnico.'
    required: true
    hints:
      - 'Un switch sobre Object puede usar patrones de tipo.'
      - 'La rama por defecto cubre lo que no anticipaste, sin exponerlo.'
  - id: 'sustentar-patterns-tipo'
    kind: 'source'
    prompt: 'En Patterns, encuentra cómo se escribe un patrón que comprueba el tipo de un valor dentro de un switch.'
    required: true
    sourceLabel: 'Patterns'
    hints:
      - 'Busca los ejemplos con nombres de clase como patrón.'
      - 'Fíjate en cómo se extrae un campo al mismo tiempo.'
  - id: 'defender-generico'
    kind: 'judgment'
    prompt: 'Decide qué debería decir el mensaje por defecto para un error desconocido, y nombra el equilibrio entre no filtrar nada y no dejar a la persona sin salida.'
    required: true
    hints:
      - 'Un mensaje demasiado vago no dice si conviene reintentar.'
      - 'Un identificador de incidencia permite conectar la pantalla con el log sin exponer nada.'
docRefs:
  - label: 'Patterns'
    url: 'https://dart.dev/language/patterns'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Error handling'
    url: 'https://dart.dev/language/error-handling'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué información no debe llegar nunca a la pantalla desde un error?'
  - 'En un archivo vacío, vuelve a escribir mensajeParaUsuario con sus tres ramas, sin mirar tu solución.'
  - 'Explica en voz alta por qué el mensaje del log y el de la pantalla son dos textos distintos.'
  - 'Diseña el flujo de importar un archivo y define un fallo mínimo por etapa con su mensaje seguro.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m10_errores.dart'
  testCommand: 'fvm dart test test/m10_errores_test.dart --name m10-5'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm10-5'
  revealReference: true
---

Hay dos audiencias para un fallo, y confundirlas produce o bien mensajes inútiles o bien fugas de información.

## Dos textos, dos propósitos

|                  | Log                                 | Pantalla                               |
| ---------------- | ----------------------------------- | -------------------------------------- |
| lo lee           | quien depura                        | quien usa la app                       |
| debe tener       | tipo, stack trace, contexto técnico | qué pasó y qué hacer                   |
| nunca debe tener | —                                   | rutas, consultas, direcciones internas |

Volcar `error.toString()` en pantalla es la forma más rápida de terminar mostrando `SocketException: OS Error: Connection refused, errno = 111, address = 10.0.0.3, port = 5432`. Eso le dice a un atacante la topología de tu red y a un usuario, nada.

## Un switch sobre el tipo

```dart
String mensajeParaUsuario(Object error) => switch (error) {
  DatoInvalido(campo: final campo) => 'Revisa el campo $campo e inténtalo otra vez.',
  FormatException() => 'El formato del archivo no es el esperado.',
  _ => 'No pudimos completar la operación. Inténtalo más tarde.',
};
```

Los patrones de tipo de D08-L04, ahora sobre `Object`. Fíjate en la primera rama: extrae `campo` y lo usa. El `campo` es seguro —es un nombre de tu propio modelo—; el `motivo` no necesariamente, así que no aparece.

## Aquí el comodín sí va

En D08 argumentamos contra la rama comodín. Aquí es obligatoria, y la diferencia es el tipo: `Object` es **abierto**. Cualquier librería puede lanzar cualquier cosa, y no existe un conjunto cerrado que cubrir.

Cuando el tipo es cerrado, el comodín esconde cambios. Cuando es abierto, es lo único que evita que un error inesperado se filtre tal cual.

## Intento · antes de mirar

Reescribe estos tres para una persona, y anota qué información quitas de cada uno:

- `FormatException at line 12`
- `SocketException: 111, address = 10.0.0.3`
- `null check operator used on a null value`

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m10_errores_test.dart --name m10-5
```

Pega la salida del test que comprueba que no se filtra el motivo técnico. Ese test le pasa a propósito un motivo con pinta de ruta interna.

## Fuente · lee con una pregunta

Abre **Patterns** y busca los patrones de tipo. Pregunta concreta: ¿cómo se comprueba el tipo y se extrae un campo en el mismo patrón? Anota la sintaxis.

## Criterio · decide y acepta el costo

Defiende el mensaje por defecto. «Inténtalo más tarde» no filtra nada y tampoco dice si tiene sentido reintentar.

Una salida común es incluir un identificador de incidencia: la persona ve un código, tú lo buscas en el log y encuentras el stack trace completo. Cuesta infraestructura. Elige y nombra el costo.

Cierra el módulo:

```bash
fvm dart analyze
```

En D10 el tiempo entra en escena: operaciones que tardan y que pueden fallar mientras tanto.
