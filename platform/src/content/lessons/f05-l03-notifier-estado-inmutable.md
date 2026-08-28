---
id: 'F05-L03'
trackId: 'flutter'
moduleId: 'F05'
kind: 'taller'
order: 2
slug: 'notifier-y-estado-inmutable'
title: 'Un Notifier expone estado inmutable y comandos'
summary: 'Construye estado con copyWith, publícalo desde un Notifier y entiende por qué mutar el estado no notifica a nadie.'
estimatedMinutes: 65
objectives:
  - 'Exponer estado inmutable desde un Notifier de Riverpod.'
  - 'Usar copyWith para producir un estado nuevo en vez de mutar el actual.'
  - 'Explicar por qué mutar una lista dentro del estado no dispara una reconstrucción.'
prerequisites: ['F05-L02']
activities:
  - id: 'predecir-mutacion'
    kind: 'attempt'
    prompt: 'Sin ejecutar nada, predice qué ocurre en la interfaz si el ViewModel hace state.entries.add(nueva) en vez de asignar un estado nuevo.'
    required: true
    hints:
      - 'Riverpod compara el estado anterior con el nuevo para decidir si notifica.'
      - 'Mutar una lista no cambia la referencia de la lista.'
  - id: 'romper-inmutabilidad'
    kind: 'evidence'
    prompt: 'Cambia temporalmente un método del ViewModel para mutar la lista en vez de reasignar el estado, ejecuta las pruebas del ViewModel y pega el fallo. Después restaura el código.'
    required: true
    hints:
      - 'getAll devuelve una lista no modificable: eso ya te frena.'
      - 'Si la prueba pasa igual, revisa si estás comprobando la referencia o el contenido.'
  - id: 'sustentar-notifier'
    kind: 'source'
    prompt: 'En Notifier class, encuentra cómo se declara el estado inicial y qué ocurre al asignar la propiedad state.'
    required: true
    sourceLabel: 'Notifier class — Riverpod API'
    hints:
      - 'Busca el método build del Notifier.'
      - 'Fíjate si la página dice cuándo se notifica a los oyentes.'
  - id: 'defender-copywith'
    kind: 'judgment'
    prompt: 'Decide si el estado debe ser una clase con copyWith o un simple registro de campos sueltos, y nombra el costo de cada opción.'
    required: true
    hints:
      - 'copyWith cuesta código repetitivo y evita estados a medio actualizar.'
      - 'Campos sueltos en el Notifier obligan a recordar notificar en cada uno.'
docRefs:
  - label: 'Notifier class — Riverpod API'
    url: 'https://pub.dev/documentation/riverpod/latest/riverpod/Notifier-class.html'
    kind: 'package'
    version: 'Riverpod 3.x'
    lastVerified: '2026-08-23'
  - label: 'UI layer case study'
    url: 'https://docs.flutter.dev/app-architecture/case-study/ui-layer'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Por qué mutar una lista dentro del estado no dispara una reconstrucción?'
  - 'En un archivo vacío, vuelve a escribir una clase de estado con copyWith y un Notifier que la publique, sin mirar.'
  - 'Explica en voz alta qué hace exactamente asignar la propiedad state de un Notifier.'
  - 'Agrega un campo nuevo al estado de la bitácora y decide si copyWith necesita tratarlo de forma especial.'
lab:
  workspace: 'flutter_lab'
  targetPath: 'lib/features/journal/presentation/journal_view_model.dart'
  testCommand: 'fvm flutter test test/features/journal/presentation/journal_view_model_test.dart'
  analyzeCommand: 'fvm flutter analyze'
---

Un `Notifier` hace dos cosas: **guarda un estado** y **avisa cuando cambia**. La segunda solo funciona si respetas la primera regla: el estado no se muta, se reemplaza.

## La forma

```dart
final journalViewModelProvider =
    NotifierProvider<JournalViewModel, JournalState>(JournalViewModel.new);

class JournalViewModel extends Notifier<JournalState> {
  @override
  JournalState build() {
    _repository = ref.watch(journalRepositoryProvider);
    return JournalState(entries: _repository.getAll());
  }

  void deleteEntry(String id) {
    _repository.delete(id);
    state = JournalState(entries: _repository.getAll()); // estado nuevo
  }
}
```

`build()` produce el estado inicial. Asignar `state = ...` hace dos cosas: guarda el valor y **notifica a todo el que estuviera escuchando**.

## Por qué mutar no funciona

```dart
state.entries.add(nueva); // no pasa nada visible
```

Riverpod compara el estado anterior con el nuevo para decidir si vale la pena notificar. Si mutas la lista, la referencia de `state` sigue siendo la misma: para Riverpod nada cambió, y no notifica. El dato está actualizado y la pantalla no.

Es exactamente el mismo error que `setState` en F02, con otra cara: **modificar sin avisar**.

La bitácora se protege de esto por partida doble: `getAll()` devuelve una `List.unmodifiable`, así que mutarla lanza en ejecución — igual que la lista `const` de D01-L05.

## copyWith produce, no modifica

```dart
JournalState copyWith({List<JournalEntry>? entries, String? validationError, bool clearValidationError = false}) {
  return JournalState(
    entries: entries ?? this.entries,
    validationError: clearValidationError ? null : validationError ?? this.validationError,
  );
}
```

Cada llamada devuelve un objeto nuevo con los campos que le pasaste y el resto intacto. Fíjate en el detalle de `clearValidationError`: con `?? this.validationError` no hay forma de **borrar** un valor pasando `null`, porque `null` significa «no lo toques». Por eso hace falta la bandera explícita. Es un caso donde la ausencia tiene dos significados y hay que separarlos, otra vez el tema de D02.

## Intento · antes de mirar

Predice qué se ve en pantalla si `deleteEntry` hiciera `state.entries.remove(...)` en lugar de reasignar `state`. ¿Cambia el dato? ¿Cambia la pantalla? ¿Y si después se produce cualquier otra reconstrucción?

## Evidencia · provoca el fallo

Cambia temporalmente un método del `ViewModel` para mutar la lista en vez de reasignar el estado. Ejecuta:

```bash
cd flutter_lab
fvm flutter test test/features/journal/presentation/journal_view_model_test.dart
```

Pega el fallo. Restaura el código después.

## Fuente · lee con una pregunta

Abre **Notifier class — Riverpod API**. Dos preguntas: ¿dónde se declara el estado inicial?, ¿qué ocurre exactamente al asignar `state`? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende la clase `JournalState` con `copyWith` frente a tener los campos sueltos en el `Notifier`.

`copyWith` cuesta código repetitivo que hay que actualizar con cada campo nuevo. A cambio, el estado viaja como una sola cosa coherente: nunca hay un momento en que la lista esté actualizada y el error de validación no.

Elige y nombra el costo. En la próxima lección la pregunta pasa a ser **quién** escucha ese estado.
