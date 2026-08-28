---
id: 'D02-L03'
trackId: 'dart'
moduleId: 'D02'
kind: 'taller'
order: 2
slug: 'devolver-un-tipo-nulable'
title: 'Devolver null a propósito'
summary: 'Diseña una función que declara String? en su firma y traslada al consumidor la decisión sobre la ausencia.'
estimatedMinutes: 45
objectives:
  - 'Justificar cuándo un tipo de retorno nulable comunica mejor el contrato que un valor centinela.'
  - 'Recorrer una colección devolviendo el primer elemento que cumple una condición.'
  - 'Explicar qué obliga a hacer un retorno nulable a quien llama la función.'
prerequisites: ['D02-L02']
activities:
  - id: 'predecir-primer-no-vacio'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, escribe de memoria primerNoVacio(List<String> textos) y decide qué devuelve cuando la lista está vacía o todos son «».'
    required: true
    hints:
      - 'Un valor centinela como «» sería indistinguible de un dato real.'
      - 'La firma es la que comunica que puede no haber respuesta.'
  - id: 'resolver-m03-3'
    kind: 'evidence'
    prompt: 'Implementa primerNoVacio, ejecuta sus pruebas y pega la salida del caso sin ningún texto válido.'
    required: true
    hints:
      - 'Un for con retorno temprano basta.'
      - 'El tipo de retorno declarado ya te permite devolver null.'
  - id: 'sustentar-nullable'
    kind: 'source'
    prompt: 'En Understanding null safety, encuentra qué obliga el compilador a hacer a quien recibe un valor nulable antes de usarlo.'
    required: true
    sourceLabel: 'Understanding null safety'
    hints:
      - 'Busca la parte sobre flow analysis o definite assignment.'
      - 'Anota el encabezado y una paráfrasis corta.'
  - id: 'defender-nulable'
    kind: 'judgment'
    prompt: 'Compara devolver String? con devolver «» o con lanzar una excepción cuando no hay resultado. Elige una y nombra el costo.'
    required: true
    hints:
      - 'Una excepción convierte un caso esperado en un fallo.'
      - 'Un centinela obliga a documentar una convención que el tipo no expresa.'
docRefs:
  - label: 'Understanding null safety'
    url: 'https://dart.dev/null-safety/understanding-null-safety'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'The Dart type system'
    url: 'https://dart.dev/language/type-system'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué comunica un tipo de retorno nulable que un valor centinela no comunica?'
  - 'En un archivo vacío, vuelve a escribir primerNoVacio sin mirar tu solución.'
  - 'Explica en voz alta qué obliga a hacer un String? a quien llama la función.'
  - 'Escribe una función que busque un usuario por identificador y decide entre devolver nulable o lanzar; defiende la elección.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m03_null_safety.dart'
  testCommand: 'fvm dart test test/m03_null_safety_test.dart --name m03-3'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm03-3'
---

Hasta aquí recibiste valores que podían faltar. Ahora vas a **producir** uno, y esa es una decisión de diseño, no un accidente.

## Tres formas de decir «no hay»

Cuando una búsqueda no encuentra nada, hay tres respuestas posibles:

| Opción               | Qué comunica               | Qué cuesta                                     |
| -------------------- | -------------------------- | ---------------------------------------------- |
| devolver `String?`   | «puede no haber resultado» | quien llama debe comprobar antes de usar       |
| devolver `''`        | nada: el tipo no lo dice   | un dato real vacío se confunde con la ausencia |
| lanzar una excepción | «esto no debería pasar»    | convierte un caso esperado en un fallo         |

El centinela es el peor de los tres precisamente porque es el más cómodo de escribir: el contrato queda en un comentario que nadie lee, en vez de en la firma que el compilador comprueba.

## La firma hace el trabajo

```dart
String? primerNoVacio(List<String> textos) { ... }
```

Ese signo de interrogación obliga a todo el que use la función a decidir qué hace si no hay resultado. No es una molestia: es exactamente la conversación que querías forzar.

## Intento · antes de mirar

Escribe tu versión de memoria. Decide de antemano tres casos: lista vacía, lista con solo cadenas vacías, y lista donde el segundo elemento es el primero válido.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m03_null_safety_test.dart --name m03-3
```

Pega la salida del caso donde no hay ningún texto válido.

## Fuente · lee con una pregunta

Vuelve a **Understanding null safety**, esta vez desde el otro lado: ¿qué le exige el compilador a quien **recibe** un valor nulable antes de poder usarlo? Registra el encabezado que lo explica.

## Criterio · decide y acepta el costo

Defiende el tipo de retorno frente a las otras dos opciones de la tabla. La respuesta útil no es «nulable es lo correcto»: es explicar qué caso concreto rompe cada alternativa en este dominio.

En la próxima lección la ausencia deja de venir de una lista y empieza a venir de afuera: texto que escribió una persona.
