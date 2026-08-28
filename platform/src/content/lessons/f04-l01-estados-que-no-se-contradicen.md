---
id: 'F04-L01'
trackId: 'flutter'
moduleId: 'F04'
kind: 'taller'
order: 0
slug: 'datos-asincronos-y-persistencia'
title: 'Un Future no es un modelo de experiencia'
summary: 'Modela carga, vacío, datos y error como estados excluyentes, y dale a cada uno la acción que corresponde.'
estimatedMinutes: 55
objectives:
  - 'Modelar estados asíncronos mutuamente excluyentes con un tipo sellado.'
  - 'Distinguir una respuesta vacía de una carga en curso.'
  - 'Asignar a cada estado la acción que ofrece a la persona.'
prerequisites: ['F03-L03']
activities:
  - id: 'predecir-banderas'
    kind: 'attempt'
    prompt: 'Sin abrir el código, escribe cuántas combinaciones permiten dos banderas booleanas cargando y error, y cuántas de ellas significan algo.'
    required: true
    hints:
      - 'Dos booleanos producen cuatro combinaciones.'
      - 'Pregúntate qué pantalla dibujarías con cargando y error a la vez.'
  - id: 'resolver-estados'
    kind: 'evidence'
    prompt: 'Revisa stateFromResult y actionFor en journal_load_state.dart, ejecuta las pruebas del archivo y pega la salida del caso de la lista vacía.'
    required: true
    hints:
      - 'Una lista vacía produce JournalEmpty, no JournalData con cero elementos.'
      - 'Un estado sin acción devuelve null a propósito.'
  - id: 'sustentar-futurebuilder'
    kind: 'source'
    prompt: 'En FutureBuilder class, encuentra qué estados distingue el snapshot y cómo se comprueba cada uno.'
    required: true
    sourceLabel: 'FutureBuilder class'
    hints:
      - 'Busca connectionState y hasError.'
      - 'Fíjate en si distingue datos vacíos de ausencia de datos.'
  - id: 'defender-vacio'
    kind: 'judgment'
    prompt: 'Decide si la lista vacía merece un estado propio o puede tratarse como datos con cero elementos, y nombra qué pierde la persona con cada opción.'
    required: true
    hints:
      - 'Una lista vacía y una lista con datos ofrecen acciones distintas.'
      - 'Un estado más es una rama más que mantener en cada switch.'
docRefs:
  - label: 'FutureBuilder class'
    url: 'https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html'
    kind: 'api'
    version: 'API estable'
    lastVerified: '2026-08-23'
  - label: 'Fetch data from the internet'
    url: 'https://docs.flutter.dev/cookbook/networking/fetch-data'
    kind: 'cookbook'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué estados necesita una carga y qué acción ofrece cada uno?'
  - 'En un archivo vacío, vuelve a escribir el tipo sellado de estados de carga, sin mirar la lección.'
  - 'Explica en voz alta por qué dos banderas booleanas permiten estados que no significan nada.'
  - 'Modela los estados de una pantalla de búsqueda y define la acción de cada uno.'
lab:
  workspace: 'flutter_lab'
  targetPath: 'lib/features/journal/presentation/journal_load_state.dart'
  testCommand: 'fvm flutter test test/features/journal/presentation/journal_load_state_test.dart'
  analyzeCommand: 'fvm flutter analyze'
---

Un `Future` tiene dos finales: valor o error. Una pantalla tiene más, y modelarla con las herramientas del `Future` produce interfaces que se contradicen.

## El problema de las banderas

```dart
bool cargando = false;
bool hayError = false;
List<JournalEntry> entradas = <JournalEntry>[];
```

Dos booleanos permiten **cuatro** combinaciones, y solo tres significan algo. `cargando && hayError` no corresponde a ninguna pantalla, y sin embargo se puede escribir — y va a ocurrir el día que alguien olvide poner una en `false`.

Agrega una tercera bandera y son ocho combinaciones para cuatro estados reales.

## Estados excluyentes

```dart
sealed class JournalLoadState {
  const JournalLoadState();
}

final class JournalLoading extends JournalLoadState { const JournalLoading(); }
final class JournalEmpty extends JournalLoadState { const JournalEmpty(); }
final class JournalData extends JournalLoadState {
  const JournalData(this.entries);
  final List<JournalEntry> entries;
}
final class JournalFailure extends JournalLoadState {
  const JournalFailure(this.message);
  final String message;
}
```

Cuatro estados, y **solo cuatro**. No hay forma de estar cargando y fallando a la vez. Es el tipo sellado de D08-L04 aplicado a una pantalla, y el `switch` que lo consume vuelve a ser exhaustivo sin comodín.

Fíjate también en que cada variante lleva **solo** lo que necesita: `JournalLoading` no tiene lista, `JournalFailure` no tiene entradas.

## Vacío no es lo mismo que datos

```dart
JournalLoadState stateFromResult(List<JournalEntry> entries) =>
    entries.isEmpty ? const JournalEmpty() : JournalData(entries);
```

Una lista vacía podría representarse como `JournalData([])`. Sería correcto y perdería la distinción que importa: **son dos pantallas distintas con dos acciones distintas**.

```dart
String? actionFor(JournalLoadState state) => switch (state) {
  JournalLoading() => null,
  JournalEmpty() => 'Crear la primera entrada',
  JournalData() => null,
  JournalFailure() => 'Reintentar',
};
```

Cada estado declara qué puede hacer la persona. Un estado sin acción devuelve `null` a propósito; un estado sin salida —error sin reintentar, vacío sin crear— deja atrapado a quien lo encuentre.

## Intento · antes de mirar

Escribe las cuatro combinaciones de `cargando` y `hayError`, y anota qué pantalla dibujarías con cada una. La que no puedas describir es el argumento de esta lección.

## Evidencia · ejecuta y compara

```bash
cd flutter_lab
fvm flutter test test/features/journal/presentation/journal_load_state_test.dart
```

Pega la salida del caso de la lista vacía. Ese test comprueba `isA<JournalEmpty>()`, no `isA<JournalData>()`.

## Fuente · lee con una pregunta

Abre **FutureBuilder class** con una pregunta concreta: ¿qué estados distingue el `snapshot` y distingue una lista vacía de la ausencia de datos? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende el estado vacío propio. El costo es una rama más en cada `switch` que consuma el estado, y con cinco pantallas eso se nota.

Elige y nombra el costo. En la próxima lección aparece la fuente que produce esos estados — y que puede fallar cuando tú se lo pidas.
