---
id: 'D05-L02'
trackId: 'dart'
moduleId: 'D05'
kind: 'taller'
order: 1
slug: 'normalizar-antes-de-deduplicar'
title: 'Normalizar antes de deduplicar'
summary: 'Descubre por qué un Set no elimina duplicados que tu dominio considera iguales, y dónde va la normalización.'
estimatedMinutes: 45
objectives:
  - 'Explicar qué considera «igual» un Set y por qué no siempre coincide con tu dominio.'
  - 'Normalizar datos antes de deduplicarlos.'
  - 'Decidir en qué capa vive una regla de normalización.'
prerequisites: ['D05-L01']
activities:
  - id: 'predecir-set'
    kind: 'attempt'
    prompt: 'Sin ejecutar nada, predice cuántos elementos quedan al meter « Dart », «dart» y «DART» en un Set<String>, y por qué.'
    required: true
    hints:
      - 'Un Set usa == y hashCode para decidir si dos elementos son el mismo.'
      - 'Para un String, «Dart» y «dart» no son iguales.'
  - id: 'resolver-m06-2'
    kind: 'evidence'
    prompt: 'Implementa etiquetasUnicas y ejecuta sus pruebas. Pega la salida del caso que mezcla mayúsculas con espacios.'
    required: true
    hints:
      - 'Normaliza antes de meter al Set, no después.'
      - 'Una cadena que queda vacía tras recortar no es una etiqueta.'
  - id: 'sustentar-set'
    kind: 'source'
    prompt: 'En Collections, localiza la sección de sets y encuentra qué usa un Set para decidir si dos elementos son el mismo.'
    required: true
    sourceLabel: 'Collections'
    hints:
      - 'Busca si menciona == o hashCode.'
      - 'Anota el encabezado y una paráfrasis.'
  - id: 'defender-normalizacion'
    kind: 'judgment'
    prompt: 'Decide si la normalización debe ocurrir al guardar la etiqueta o al compararla, y nombra el costo de cada opción.'
    required: true
    hints:
      - 'Normalizar al guardar pierde la forma original que escribió la persona.'
      - 'Normalizar al comparar repite la regla en cada punto de uso.'
docRefs:
  - label: 'Collections'
    url: 'https://dart.dev/language/collections'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Built-in types'
    url: 'https://dart.dev/language/built-in-types'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué usa un Set para decidir que dos elementos son el mismo?'
  - 'En un archivo vacío, vuelve a escribir etiquetasUnicas sin mirar tu solución.'
  - 'Explica en voz alta por qué un Set no deduplica « Dart » y «dart».'
  - 'Deduplica una lista de correos electrónicos y decide qué parte del texto conviene normalizar.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m06_colecciones.dart'
  testCommand: 'fvm dart test test/m06_colecciones_test.dart --name m06-2'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm06-2'
---

Un `Set` promete que no habrá elementos repetidos. La letra chica está en qué considera «repetido».

## Igualdad estructural, no semántica

Un `Set` decide con `==` y `hashCode`. Para un `String`, eso significa comparación exacta de caracteres:

```dart
<String>{' Dart ', 'dart', 'DART'}.length; // 3
```

Tres elementos. Para el `Set` son tres textos distintos, y tiene razón: nadie le dijo que en tu dominio el espaciado y las mayúsculas no cuentan.

Esa regla es tuya, no del lenguaje. Y si es tuya, tienes que escribirla.

## La normalización va antes

```dart
etiquetas
    .map((etiqueta) => etiqueta.trim().toLowerCase())
    .where((etiqueta) => etiqueta.isNotEmpty)
    .toSet();
```

El orden importa. Normalizar **después** de meter al `Set` no sirve de nada: la deduplicación ya ocurrió sobre los valores sin normalizar.

Fíjate también en el `where`: una cadena que queda vacía después de recortar no es una etiqueta vacía, es **ninguna etiqueta**. Es la misma distinción entre ausencia y vacío que trabajaste en D02.

## Intento · antes de mirar

Predice cuántos elementos quedan en cada caso, y por qué:

```dart
<String>{' Dart ', 'dart', 'DART'}
<String>{'dart', 'dart'}
<String>{'', '   '}
```

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m06_colecciones_test.dart --name m06-2
```

Pega la salida del caso que mezcla mayúsculas con espacios. Prueba a propósito una versión que normalice **después** del `toSet()` y observa qué test se rompe.

## Fuente · lee con una pregunta

Abre **Collections**, sección de sets. Pregunta concreta: ¿qué usa un `Set` para decidir si dos elementos son el mismo? Anota el encabezado.

## Criterio · decide y acepta el costo

¿Guardas la etiqueta ya normalizada, o guardas lo que escribió la persona y normalizas al comparar?

Normalizar al guardar simplifica todo lo demás y pierde la forma original —«Dart» escrito con mayúscula deja de existir—. Normalizar al comparar conserva el texto y obliga a repetir la regla en cada punto donde compares, con el riesgo de olvidarte en uno.

Elige y nombra el costo. En la próxima lección el problema deja de ser deduplicar y pasa a ser **qué hacer** cuando dos elementos compiten por el mismo lugar.
