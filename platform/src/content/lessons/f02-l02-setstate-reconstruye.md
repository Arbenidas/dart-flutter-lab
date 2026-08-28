---
id: 'F02-L02'
trackId: 'flutter'
moduleId: 'F02'
kind: 'taller'
order: 1
slug: 'setstate-reconstruye-no-guarda'
title: 'setState reconstruye; no guarda'
summary: 'Separa el widget que se descarta en cada build del objeto State que persiste, y comprueba qué sobrevive a cada cosa.'
estimatedMinutes: 55
objectives:
  - 'Distinguir reconstruir un Widget de destruir su State.'
  - 'Explicar qué hace exactamente setState y qué no hace.'
  - 'Predecir qué datos sobreviven a una reconstrucción y cuáles a cerrar la pantalla.'
prerequisites: ['F02-L01']
activities:
  - id: 'predecir-supervivencia'
    kind: 'attempt'
    prompt: 'Sin ejecutar la app, predice qué datos sobreviven cuando el diálogo ejecuta setState y cuáles sobreviven cuando el diálogo se cierra y se vuelve a abrir.'
    required: true
    hints:
      - 'El widget se descarta y se crea de nuevo en cada build; el State no.'
      - 'Cerrar el diálogo saca su Element del árbol.'
  - id: 'contar-builds'
    kind: 'evidence'
    prompt: 'Agrega un contador en el State del diálogo que aumente en cada build e imprímelo. Abre el diálogo, escribe, ciérralo y vuelve a abrirlo. Pega la secuencia de números.'
    required: true
    hints:
      - 'Escribir dispara setState y por tanto un build más.'
      - 'Al reabrir, el contador vuelve a empezar: eso es un State nuevo.'
  - id: 'sustentar-setstate'
    kind: 'source'
    prompt: 'En State class, encuentra qué hace setState según la documentación y qué ocurre si modificas un campo sin llamarlo.'
    required: true
    sourceLabel: 'State class'
    hints:
      - 'Busca el método setState dentro de la página.'
      - 'Fíjate si menciona que notifica al framework.'
  - id: 'defender-stateful'
    kind: 'judgment'
    prompt: 'Decide si el diálogo de edición debería ser StatefulWidget o recibir todo desde el ViewModel, y nombra el costo de cada opción.'
    required: true
    hints:
      - 'Un campo de texto necesita un controller que vive entre reconstrucciones.'
      - 'Subir cada pulsación de tecla al ViewModel reconstruye toda la feature.'
docRefs:
  - label: 'State class'
    url: 'https://api.flutter.dev/flutter/widgets/State-class.html'
    kind: 'api'
    version: 'API estable'
    lastVerified: '2026-08-23'
  - label: 'StatelessWidget class'
    url: 'https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html'
    kind: 'api'
    version: 'API estable'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué diferencia hay entre reconstruir un Widget y destruir su State?'
  - 'En un archivo vacío, escribe un StatefulWidget mínimo con un contador y setState, sin mirar la lección.'
  - 'Explica en voz alta qué hace setState y qué pasa si modificas un campo sin llamarlo.'
  - 'Toma un widget con estado de otro proyecto y predice qué se pierde al cerrarlo; compruébalo.'
lab:
  workspace: 'flutter_lab'
  targetPath: 'lib/features/journal/presentation/widgets/journal_editor_dialog.dart'
  testCommand: 'fvm flutter test test/features/journal/presentation/journal_view_test.dart'
  analyzeCommand: 'fvm flutter analyze'
---

`setState` es la primera API de estado que aprende todo el mundo y casi siempre se entiende mal. No guarda nada. Solo avisa.

## Dos objetos con vidas distintas

```dart
class JournalEditorDialog extends StatefulWidget { ... }   // se descarta y recrea
class _JournalEditorDialogState extends State<...> { ... } // persiste
```

El **widget** es una descripción: se crea y se tira en cada reconstrucción, igual que viste en F00. El **State** es un objeto que el framework mantiene vivo, asociado al `Element`, mientras ese `Element` siga en el árbol.

Por eso los campos que deben sobrevivir a un `build` van en el `State`, no en el widget. Y por eso los campos del widget son `final`: no tendría sentido mutarlos, ese objeto ya va a ser reemplazado.

## Qué hace setState

```dart
setState(() {
  _titulo = nuevoValor;
});
```

Dos cosas, en este orden:

1. Ejecuta tu función, que modifica campos del `State`.
2. **Marca el elemento como sucio** para que Flutter lo reconstruya.

Si modificas `_titulo` sin `setState`, el valor **sí cambia** — pero nadie pide una reconstrucción, así que la pantalla sigue mostrando el anterior. Ese es el bug clásico de «el dato está bien pero no se ve».

Al revés también: llamar a `setState` con un cuerpo vacío reconstruye igual. La función no es donde ocurre la magia; es solo el lugar convenido para hacer el cambio.

## Dos preguntas que se confunden

- **¿Sobrevive a un `setState`?** Sí, si está en el `State`.
- **¿Sobrevive a cerrar el diálogo?** No. Cerrarlo saca su `Element` del árbol, se llama a `dispose` y el `State` desaparece con todo lo que tenía.

Esa segunda pregunta es la que decide si un dato puede vivir aquí o tiene que subir, que es exactamente la conversación de la lección anterior.

## Intento · antes de mirar

Completa la tabla antes de ejecutar nada:

| Dato                 | ¿sobrevive a setState? | ¿sobrevive a cerrar y reabrir? |
| -------------------- | ---------------------- | ------------------------------ |
| el texto escrito     | ?                      | ?                              |
| la lista de entradas | ?                      | ?                              |

## Evidencia · ejecuta y compara

Agrega un contador en el `State` del diálogo:

```dart
int _builds = 0;

@override
Widget build(BuildContext context) {
  debugPrint('build ${++_builds}');
  ...
}
```

Abre el diálogo, escribe unas letras, ciérralo y vuelve a abrirlo. Pega la secuencia de números. El salto de vuelta a `1` al reabrir es la prueba de que el `State` anterior ya no existe.

Quita el contador cuando termines.

## Fuente · lee con una pregunta

Abre **State class** y busca `setState`. Pregunta concreta: ¿qué dice que hace, y qué advierte sobre modificar campos sin llamarlo? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende si el diálogo debe ser `StatefulWidget` o recibir todo desde el `ViewModel`.

A favor del `State` local: un campo de texto necesita un controller que viva entre reconstrucciones, y subir cada pulsación de tecla al `ViewModel` reconstruiría toda la feature en cada letra. En contra: el borrador se pierde al cerrar, y eso puede ser exactamente lo que no quieres.

Elige y nombra el costo. En la próxima lección aparece la otra mitad del `State`: lo que hay que **liberar**.
