---
id: 'F05-L04'
trackId: 'flutter'
moduleId: 'F05'
kind: 'taller'
order: 3
slug: 'watch-read-y-quien-se-reconstruye'
title: 'watch escucha; read solo pregunta una vez'
summary: 'Elige entre ref.watch y ref.read según si quieres reconstrucciones, y controla el alcance de cada una.'
estimatedMinutes: 55
objectives:
  - 'Distinguir ref.watch de ref.read por su efecto sobre las reconstrucciones.'
  - 'Explicar por qué usar watch dentro de un callback es un error.'
  - 'Reducir el alcance de una reconstrucción moviendo el watch más abajo.'
prerequisites: ['F05-L03']
activities:
  - id: 'predecir-rebuilds'
    kind: 'attempt'
    prompt: 'Sin ejecutar nada, predice qué widgets se reconstruyen al crear una entrada si el watch está en la raíz de la vista, y cuáles si estuviera solo en la lista.'
    required: true
    hints:
      - 'watch suscribe al widget que lo llama, no a sus hijos.'
      - 'Cuanto más arriba esté el watch, más ancha es la reconstrucción.'
  - id: 'contar-rebuilds'
    kind: 'evidence'
    prompt: 'Agrega un debugPrint en el build de JournalView y en el de un widget hijo, crea una entrada y pega cuántas veces se ejecutó cada uno.'
    required: true
    hints:
      - 'Un print por build alcanza para ver el alcance.'
      - 'Compara antes y después de mover el watch más abajo.'
  - id: 'sustentar-watch'
    kind: 'source'
    prompt: 'En Notifier class o en la documentación de Riverpod enlazada, encuentra la diferencia entre observar un provider y leerlo una sola vez.'
    required: true
    sourceLabel: 'Notifier class — Riverpod API'
    hints:
      - 'Busca los nombres watch y read en la página.'
      - 'Fíjate en qué contexto recomienda cada uno.'
  - id: 'defender-alcance'
    kind: 'judgment'
    prompt: 'Decide si conviene un watch en la raíz de la vista o varios watch más abajo, y nombra el costo de cada opción.'
    required: true
    hints:
      - 'Un watch arriba es simple de leer y reconstruye de más.'
      - 'Varios watch abajo afinan el alcance y dispersan de dónde salen los datos.'
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
  - '¿Qué diferencia existe entre ref.watch(provider) y ref.read(provider.notifier)?'
  - 'En un archivo vacío, escribe un ConsumerWidget que observe un estado y llame a una acción, sin mirar la lección.'
  - 'Explica en voz alta por qué usar watch dentro de un callback es un error.'
  - 'Reduce el alcance de una reconstrucción en otro proyecto moviendo el punto de suscripción.'
lab:
  workspace: 'flutter_lab'
  targetPath: 'lib/features/journal/presentation/journal_view.dart'
  testCommand: 'fvm flutter test test/features/journal/presentation/journal_view_model_test.dart'
  analyzeCommand: 'fvm flutter analyze'
---

`ref.watch` y `ref.read` se parecen tanto que la mayoría los usa al azar hasta que algo no se actualiza o algo se actualiza de más.

## Dos verbos distintos

```dart
// leer estado y suscribirse: reconstruye este widget cuando cambie
final state = ref.watch(journalViewModelProvider);

// obtener el objeto para llamar un método: sin suscripción
ref.read(journalViewModelProvider.notifier).deleteEntry(id);
```

|             | `watch`              | `read`                                           |
| ----------- | -------------------- | ------------------------------------------------ |
| se suscribe | sí                   | no                                               |
| va en       | el cuerpo de `build` | callbacks: `onPressed`, `onTap`                  |
| te da       | el **estado**        | normalmente el **notifier**, para llamar métodos |

La regla que resuelve el 90 %: **`watch` en `build`, `read` en callbacks**.

## Por qué watch en un callback es un error

Un `onPressed` se ejecuta una vez, cuando alguien pulsa. Suscribirse ahí no tiene sentido: no hay nada que reconstruir en respuesta, y la suscripción se registra fuera de la fase donde Riverpod la espera. Lo que querías es preguntar el valor actual y actuar: eso es `read`.

## El alcance de un watch

Aquí está la parte que importa para el rendimiento. `ref.watch` suscribe **al widget que lo llama**. Si está en la raíz de `JournalView`, cualquier cambio de estado reconstruye la pantalla entera, incluido el encabezado que solo muestra un contador.

Bajar el `watch` al widget que de verdad usa el dato estrecha la reconstrucción:

```dart
// arriba: todo se reconstruye
final state = ref.watch(journalViewModelProvider);
return Column(children: [_Header(count: state.entries.length), _List(entries: state.entries)]);

// abajo: cada uno se reconstruye por su cuenta
return const Column(children: [_HeaderConsumer(), _ListConsumer()]);
```

La primera versión se lee mejor. La segunda reconstruye menos. Cuál conviene depende del tamaño del árbol, y es justo la decisión que cierra esta lección.

## Intento · antes de mirar

Predice, antes de ejecutar, qué widgets se reconstruyen al crear una entrada con el `watch` en la raíz de la vista. Después predice lo mismo si el `watch` estuviera solo dentro de la lista.

## Evidencia · ejecuta y compara

Agrega un `debugPrint` en el `build` de `JournalView` y en el de un widget hijo. Crea una entrada y pega cuántas veces se ejecutó cada uno.

Después mueve el `watch` más abajo y repite la medición. La diferencia entre las dos cuentas es el argumento de la sección anterior, medido en tu propia app.

## Fuente · lee con una pregunta

Abre **Notifier class — Riverpod API** y busca `watch` y `read`. Pregunta concreta: ¿en qué contexto recomienda cada uno? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende una postura para esta app: ¿un `watch` en la raíz o varios más abajo?

Un `watch` arriba se lee de un vistazo: entras al archivo y sabes de dónde salen todos los datos. Varios `watch` abajo reconstruyen menos y obligan a saltar entre widgets para reconstruir mentalmente el flujo.

Con un árbol de este tamaño, la simplicidad probablemente gane. Nombra a partir de qué señal cambiarías de opinión — y fíjate en que ahora tienes cómo medirla.

En la última lección del módulo el `Repository` se vuelve sustituible, y con eso las pruebas se vuelven baratas.
