---
id: 'D05-L04'
trackId: 'dart'
moduleId: 'D05'
kind: 'taller'
order: 3
slug: 'agrupar-y-contar-por-clave'
title: 'Acumular en un mapa sin perder el primer caso'
summary: 'Combina null safety con acumulación para contar por clave, y reconoce el patrón en cualquier agregación.'
estimatedMinutes: 45
objectives:
  - 'Componer el patrón de acumulación en un mapa con un valor por defecto.'
  - 'Explicar por qué la primera aparición de una clave necesita un caso propio.'
  - 'Reconocer el mismo patrón en agrupaciones y sumas.'
prerequisites: ['D05-L03']
activities:
  - id: 'predecir-acumulador'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, escribe cómo incrementarías el contador de una clave que puede no existir todavía, e indica el tipo de mapa[k] antes de tu operación.'
    required: true
    hints:
      - 'El acceso a un mapa con una clave ausente devuelve null.'
      - 'Recuerda D02: ?? convierte esa ausencia en un valor con el que se puede operar.'
  - id: 'resolver-m06-4'
    kind: 'evidence'
    prompt: 'Implementa contarPorClave y ejecuta sus pruebas. Pega la salida del caso donde una clave aparece tres veces.'
    required: true
    hints:
      - 'El patrón es mapa[k] = (mapa[k] ?? 0) + 1.'
      - 'Una colección vacía debe producir un mapa vacío, no un error.'
  - id: 'sustentar-map'
    kind: 'source'
    prompt: 'En Collections, localiza la sección de mapas y encuentra qué devuelve el acceso con una clave que no existe.'
    required: true
    sourceLabel: 'Collections'
    hints:
      - 'Busca si menciona null explícitamente.'
      - 'Fíjate si nombra alguna alternativa como putIfAbsent.'
  - id: 'defender-acumulador'
    kind: 'judgment'
    prompt: 'Compara tu versión con una que use putIfAbsent o update, y elige una para un proyecto real nombrando el costo.'
    required: true
    hints:
      - 'El patrón con ?? se lee sin conocer la API del mapa.'
      - 'update comunica la intención pero exige recordar su parámetro ifAbsent.'
docRefs:
  - label: 'Collections'
    url: 'https://dart.dev/language/collections'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Understanding null safety'
    url: 'https://dart.dev/null-safety/understanding-null-safety'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué devuelve el acceso a un mapa con una clave que no existe?'
  - 'En un archivo vacío, vuelve a escribir contarPorClave sin mirar tu solución.'
  - 'Explica en voz alta por qué la primera aparición de una clave necesita un valor por defecto.'
  - 'Adapta el patrón para acumular la suma de un campo en vez de contar apariciones.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m06_colecciones.dart'
  testCommand: 'fvm dart test test/m06_colecciones_test.dart --name m06-4'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm06-4'
---

Contar cuántos elementos caen en cada categoría es una de esas tareas que aparecen cada dos semanas. El patrón que la resuelve combina dos cosas que ya sabes por separado.

## El problema del primer caso

```dart
conteo[clave] = conteo[clave] + 1; // no compila
```

No compila, y el motivo es información: `conteo[clave]` tiene tipo `int?`, porque la clave puede no estar todavía. La primera vez que aparece una categoría, no hay nada que incrementar.

## El patrón

```dart
conteo[clave] = (conteo[clave] ?? 0) + 1;
```

`?? 0` convierte la ausencia en un valor con el que se puede operar. Es exactamente la herramienta de D02-L01, aplicada a un acumulador.

Léelo como una frase: _«lo que ya había, o cero si no había nada, más uno»_.

## El mismo patrón, otras formas

Dart ofrece dos alternativas:

```dart
conteo.update(clave, (actual) => actual + 1, ifAbsent: () => 1);
conteo.putIfAbsent(clave, () => 0);
```

`update` dice explícitamente «actualiza», y necesitas recordar el parámetro `ifAbsent` o lanza cuando la clave no existe. El patrón con `??` se lee sin conocer esa API.

Y el patrón generaliza más allá de contar: cambia el `+ 1` por `+ pedido.total` y tienes una suma por categoría; cambia el acumulador por una lista y tienes una agrupación.

## Intento · antes de mirar

Escribe, antes de tocar el archivo, el tipo de `conteo[clave]` **antes** de tu operación, y qué devuelve tu función con una colección vacía.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m06_colecciones_test.dart --name m06-4
```

Pega la salida del caso donde una clave aparece tres veces. Prueba también la versión que no compila: leer el error de tipo completo vale más que evitarlo.

## Fuente · lee con una pregunta

Abre **Collections**, sección de mapas. Pregunta concreta: ¿qué devuelve el acceso con una clave inexistente, y qué alternativas ofrece la API? Anota el encabezado.

## Criterio · decide y acepta el costo

Elige entre el patrón con `??` y `update`. El primero es legible sin conocer la API y repite el nombre de la clave dos veces; el segundo comunica la intención y añade una firma que hay que recordar bien.

Nombra tu elección y su costo. En la última lección del módulo vuelve la evaluación perezosa, y esta vez es medible.
