---
id: 'D08-L03'
trackId: 'dart'
moduleId: 'D08'
kind: 'taller'
order: 2
slug: 'records-con-campos-nombrados'
title: 'Devolver dos cosas sin inventar una clase'
summary: 'Usa un record con campos nombrados como tipo de retorno y decide cuándo eso ya no alcanza.'
estimatedMinutes: 45
objectives:
  - 'Declarar y devolver un record con campos nombrados.'
  - 'Explicar qué forma parte del tipo de un record.'
  - 'Decidir cuándo un record debe convertirse en una clase.'
prerequisites: ['D08-L02']
activities:
  - id: 'predecir-record'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, escribe el tipo de retorno de una función que separe una colección en dos grupos, usando un record con nombres.'
    required: true
    hints:
      - 'Los campos nombrados se declaran entre paréntesis con dos puntos.'
      - 'Un record posicional obligaría a recordar cuál venía primero.'
  - id: 'resolver-m09-3'
    kind: 'evidence'
    prompt: 'Implementa separar conservando el orden dentro de cada grupo. Ejecuta sus pruebas y pega la salida del test del orden.'
    required: true
    hints:
      - 'Una sola pasada alcanza: elige la lista destino dentro del ciclo.'
      - 'Devolver dos listas vacías es el resultado correcto para una entrada vacía.'
  - id: 'sustentar-records'
    kind: 'source'
    prompt: 'En Records, encuentra qué forma parte del tipo de un record y cómo se declaran los campos nombrados.'
    required: true
    sourceLabel: 'Records'
    hints:
      - 'Busca la parte sobre record types y shape.'
      - 'Fíjate si el nombre del campo forma parte del tipo.'
  - id: 'defender-record-o-clase'
    kind: 'judgment'
    prompt: 'Decide a partir de qué momento este record debería convertirse en una clase con nombre, y nombra qué gana la clase.'
    required: true
    hints:
      - 'Un record no puede validar nada ni tener métodos propios.'
      - 'Una clase con nombre aparece en los mensajes de error y en el autocompletado.'
docRefs:
  - label: 'Records'
    url: 'https://dart.dev/language/records'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Patterns'
    url: 'https://dart.dev/language/patterns'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué forma parte de la shape y por tanto del tipo de un record?'
  - 'En un archivo vacío, vuelve a escribir separar con su record de retorno, sin mirar tu solución.'
  - 'Explica en voz alta la diferencia entre un record posicional y uno con campos nombrados.'
  - 'Convierte el record de separar en una clase con nombre y decide si el cambio mejoró algo.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m09_modelado.dart'
  testCommand: 'fvm dart test test/m09_modelado_test.dart --name m09-3'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm09-3'
---

Una función que necesita devolver dos cosas tiene tres salidas: inventar una clase, devolver una lista de dos elementos, o usar un record. La segunda es la peor y es la más frecuente.

## El problema de la lista

```dart
List<List<int>> separar(...) // ¿cuál era cuál?
```

Quien la use tiene que recordar que el índice 0 son los que cumplen. Nada en el tipo lo dice, y nada impide invertirlos.

## El record con nombres

```dart
({List<T> cumplen, List<T> resto}) separar<T>(
  Iterable<T> elementos,
  bool Function(T) condicion,
) { ... }

final resultado = separar<int>(<int>[1, 2, 3, 4], (n) => n.isEven);
resultado.cumplen; // [2, 4]
resultado.resto;   // [1, 3]
```

Los nombres están en el **tipo**. El editor los ofrece al escribir `resultado.` y el compilador rechaza `resultado.cumplan`.

## La shape es el tipo

En D03-L03 viste records posicionales: `(int, int)`. Con campos nombrados, el nombre forma parte del tipo igual que la posición:

- `({int alto, int ancho})` y `({int ancho, int alto})` son el **mismo** tipo — el orden de los campos nombrados no importa.
- `({int alto, int ancho})` y `(int, int)` son tipos **distintos**.

No hace falta declarar nada por adelantado: el tipo existe por su forma.

## Una pasada, no dos

```dart
for (final elemento in elementos) {
  (condicion(elemento) ? cumplen : resto).add(elemento);
}
```

La alternativa obvia —`where(condicion)` y `where((e) => !condicion(e))`— evalúa la condición dos veces por elemento. Con un predicado caro, eso importa; con uno que tenga efectos, es un bug.

## Intento · antes de mirar

Escribe el tipo de retorno completo antes de abrir el archivo, y decide qué devuelve tu función con una colección vacía.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m09_modelado_test.dart --name m09-3
```

Pega la salida del test del orden dentro de cada grupo.

## Fuente · lee con una pregunta

Abre **Records** con una pregunta concreta: ¿forma parte del tipo el nombre de un campo? Anota el encabezado y el término que usa la documentación para la forma de un record.

## Criterio · decide y acepta el costo

¿Cuándo este record debería ser una clase `Particion<T>`?

Un record no puede validar nada, no tiene métodos propios y no aparece con nombre en los mensajes de error — verás `({List<int> cumplen, List<int> resto})` en cada diagnóstico. Una clase resuelve las tres cosas y cuesta un archivo más.

Nombra tu umbral. En la próxima lección aparece la herramienta que hace imposibles los estados imposibles.
