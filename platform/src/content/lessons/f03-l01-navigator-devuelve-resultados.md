---
id: 'F03-L01'
trackId: 'flutter'
moduleId: 'F03'
kind: 'taller'
order: 0
slug: 'navegacion-formularios-accesibilidad'
title: 'Navigator es una pila que devuelve resultados'
summary: 'Modela push y pop como operaciones sobre una pila y recibe un resultado tipado al cerrar una ruta o un diálogo.'
estimatedMinutes: 55
objectives:
  - 'Explicar la relación entre push, pop y el Future que devuelve una ruta.'
  - 'Devolver un resultado tipado al cerrar un diálogo y consumirlo en quien lo abrió.'
  - 'Reconocer por qué usar el contexto después de un await necesita una comprobación.'
prerequisites: ['F02-L03']
activities:
  - id: 'predecir-resultado'
    kind: 'attempt'
    prompt: 'Sin abrir el código, escribe qué valor recibe quien esperó showDialog cuando el usuario confirma, cuando cancela y cuando toca fuera del diálogo.'
    required: true
    hints:
      - 'El tipo del resultado es nulable por una de esas tres razones.'
      - 'pop puede llevar un argumento o ninguno.'
  - id: 'rastrear-confirmacion'
    kind: 'evidence'
    prompt: 'En journal_view.dart, sigue el diálogo de confirmación de borrado desde showDialog hasta el uso del resultado. Ejecuta las pruebas de la vista y pega la salida.'
    required: true
    hints:
      - 'Busca las dos llamadas a Navigator.pop con valores distintos.'
      - 'Fíjate en qué hace el código cuando el resultado no es verdadero.'
  - id: 'sustentar-navigator'
    kind: 'source'
    prompt: 'En Navigator class, encuentra qué devuelve push y cómo se entrega el valor pasado a pop.'
    required: true
    sourceLabel: 'Navigator class'
    hints:
      - 'Busca el tipo de retorno de push en la firma.'
      - 'Fíjate en la relación entre el parámetro de tipo y el argumento de pop.'
  - id: 'defender-resultado'
    kind: 'judgment'
    prompt: 'Decide si confirmar un borrado debe devolver un bool nulable o un tipo propio con tres casos, y nombra qué información se pierde con el bool.'
    required: true
    hints:
      - 'Cancelar y tocar fuera producen el mismo valor con un bool nulable.'
      - 'Un tipo propio cuesta más código y distingue los tres finales.'
docRefs:
  - label: 'Navigation and routing'
    url: 'https://docs.flutter.dev/ui/navigation'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Navigator class'
    url: 'https://api.flutter.dev/flutter/widgets/Navigator-class.html'
    kind: 'api'
    version: 'API estable'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué relación existe entre push, pop y el Future que devuelve una ruta?'
  - 'En un archivo vacío, vuelve a escribir un showDialog que devuelva un bool y su consumo, sin mirar la lección.'
  - 'Explica en voz alta por qué el resultado de un diálogo suele ser nulable.'
  - 'Diseña un flujo de dos pantallas donde la segunda devuelva un dato elegido; define el tipo del resultado antes del código.'
lab:
  workspace: 'flutter_lab'
  targetPath: 'lib/features/journal/presentation/journal_view.dart'
  testCommand: 'fvm flutter test test/features/journal/presentation/journal_view_test.dart'
  analyzeCommand: 'fvm flutter analyze'
---

Navegar en Flutter es operar sobre una pila. Lo interesante no es apilar: es que **desapilar devuelve un valor**.

## push apila, pop desapila con resultado

```dart
final confirmado = await showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    actions: <Widget>[
      TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
      TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Eliminar')),
    ],
  ),
);
```

`showDialog<bool>` devuelve un `Future<bool?>`. Ese `Future` se completa cuando la ruta se desapila, y su valor es **el argumento que le pasaste a `pop`**.

## Por qué el resultado es nulable

`bool?`, no `bool`. Hay tres finales posibles y solo dos pasan por tus botones:

| Cómo terminó              | Valor   |
| ------------------------- | ------- |
| pulsó Eliminar            | `true`  |
| pulsó Cancelar            | `false` |
| tocó fuera, o pulsó Atrás | `null`  |

El tercero es el que se olvida. Por eso el código de la bitácora no pregunta `if (confirmado)` sino que trata explícitamente el caso en que no hubo respuesta. Es exactamente la distinción de D02: **ausencia no es lo mismo que `false`**.

## El contexto después de un await

Entre el `await` y la línea siguiente puede pasar cualquier cosa, incluida la desaparición del widget que tenía ese `context`. Por eso, antes de usarlo después de esperar, hay que comprobar que el widget sigue montado. El analizador de Flutter tiene una regla dedicada a esto y te avisa.

## Intento · antes de mirar

Escribe los tres finales posibles del diálogo de borrado y el valor que produce cada uno. Después decide qué debería hacer la app en el tercero.

## Evidencia · ejecuta y compara

Abre `journal_view.dart` y sigue el diálogo de confirmación desde `showDialog` hasta donde se usa el resultado. Localiza las dos llamadas a `pop` y la comprobación del `null`. Después ejecuta:

```bash
cd flutter_lab
fvm flutter test test/features/journal/presentation/journal_view_test.dart
```

Pega la salida. Experimento extra: cambia `pop(false)` por `pop()` a secas y observa qué caso deja de distinguirse.

## Fuente · lee con una pregunta

Abre **Navigator class** con dos preguntas: ¿qué devuelve `push`?, ¿cómo llega a ese `Future` el valor que pasaste a `pop`? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende el tipo del resultado. Con `bool?`, cancelar y tocar fuera son distinguibles pero «no respondió» comparte forma con «no confirmó» en cuanto alguien escribe `?? false`. Con un tipo propio de tres casos —como los que construirás en D08— los tres finales quedan explícitos y cuesta más código.

Elige y nombra qué se pierde. En la próxima lección el resultado deja de ser un botón y pasa a ser un formulario que puede estar mal llenado.
