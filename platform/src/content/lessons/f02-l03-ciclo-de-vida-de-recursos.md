---
id: 'F02-L03'
trackId: 'flutter'
moduleId: 'F02'
kind: 'taller'
order: 2
slug: 'crear-y-liberar-recursos'
title: 'Lo que se crea en initState se libera en dispose'
summary: 'Maneja controllers y focus nodes en el ciclo de vida correcto y comprueba qué pasa cuando no los liberas.'
estimatedMinutes: 55
objectives:
  - 'Crear recursos en initState y liberarlos en dispose.'
  - 'Explicar por qué crear un controller dentro de build es una señal de fallo.'
  - 'Reconocer el aviso que produce un controller sin liberar.'
prerequisites: ['F02-L02']
activities:
  - id: 'predecir-controller'
    kind: 'attempt'
    prompt: 'Sin ejecutar nada, predice qué pasaría si el TextEditingController se creara dentro de build en vez de en initState.'
    required: true
    hints:
      - 'build se ejecuta muchas veces; initState una sola.'
      - 'Un controller nuevo empieza con el texto vacío.'
  - id: 'quitar-dispose'
    kind: 'evidence'
    prompt: 'Comenta la llamada a dispose del controller, abre y cierra el diálogo varias veces y pega el aviso que aparece en la consola. Después restaura el dispose.'
    required: true
    hints:
      - 'Flutter avisa en modo depuración cuando un objeto con dispose queda sin liberar.'
      - 'El aviso nombra la clase del objeto que quedó vivo.'
  - id: 'sustentar-dispose'
    kind: 'source'
    prompt: 'En State.dispose, encuentra qué obligación describe la documentación y en qué momento se llama.'
    required: true
    sourceLabel: 'State.dispose'
    hints:
      - 'Fíjate si dice que debe llamarse a super.dispose.'
      - 'Anota el encabezado y el orden recomendado.'
  - id: 'defender-owner-controller'
    kind: 'judgment'
    prompt: 'Decide si el controller debe crearlo el diálogo o recibirlo por parámetro desde quien lo abre, y nombra quién queda responsable de liberarlo en cada caso.'
    required: true
    hints:
      - 'Quien crea un recurso suele ser quien debe liberarlo.'
      - 'Recibirlo por parámetro permite conservar el texto entre aperturas.'
docRefs:
  - label: 'State.dispose'
    url: 'https://api.flutter.dev/flutter/widgets/State/dispose.html'
    kind: 'api'
    version: 'API estable'
    lastVerified: '2026-08-23'
  - label: 'TextEditingController class'
    url: 'https://api.flutter.dev/flutter/widgets/TextEditingController-class.html'
    kind: 'api'
    version: 'API estable'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Por qué un controller creado en build es una señal de fallo?'
  - 'En un archivo vacío, vuelve a escribir un StatefulWidget que cree su controller en initState y lo libere en dispose, sin mirar.'
  - 'Explica en voz alta qué obligación tiene dispose y qué pasa si la incumples.'
  - 'Revisa un widget con estado de otro proyecto y comprueba que cada recurso creado tenga su liberación.'
lab:
  workspace: 'flutter_lab'
  targetPath: 'lib/features/journal/presentation/widgets/journal_editor_dialog.dart'
  testCommand: 'fvm flutter test test/features/journal/presentation/journal_view_test.dart'
  analyzeCommand: 'fvm flutter analyze'
  revealReference: true
---

Un `TextEditingController`, un `FocusNode`, un `AnimationController` o una suscripción a un stream tienen algo en común: alguien los tiene que apagar.

## El par que no se separa

```dart
late final TextEditingController _tituloController;

@override
void initState() {
  super.initState();
  _tituloController = TextEditingController(text: widget.entradaInicial?.title ?? '');
}

@override
void dispose() {
  _tituloController.dispose();
  super.dispose();
}
```

`initState` se ejecuta **una vez**, cuando el `State` entra al árbol. `dispose` se ejecuta **una vez**, cuando sale. Todo lo que se crea en el primero se libera en el segundo, y en ese orden: tus recursos primero, `super.dispose()` al final.

Fíjate además en el `late final`: es exactamente el contrato que trabajaste en D02-L05. Prometes asignarlo antes de que alguien lo lea, y `initState` es donde cumples esa promesa.

## Por qué no en `build`

```dart
@override
Widget build(BuildContext context) {
  final controller = TextEditingController(); // señal de fallo
  ...
}
```

`build` se ejecuta muchas veces. Cada ejecución crearía un controller nuevo, con el texto vacío, y el anterior quedaría vivo sin que nadie lo libere. El resultado visible es un campo que se borra solo; el invisible es una fuga.

La regla es simple: **si tiene `dispose`, no se crea en `build`**.

## Qué pasa si no lo liberas

Flutter lo detecta en modo depuración y avisa por consola nombrando la clase que quedó viva. No es un error fatal —la app sigue— y por eso es fácil ignorarlo hasta que la pantalla se abre cien veces.

## Intento · antes de mirar

Predice, por escrito, qué se vería en pantalla si el controller se creara dentro de `build`: ¿el campo funcionaría?, ¿qué pasaría al escribir la segunda letra?

## Evidencia · provoca el fallo

Comenta la llamada a `_tituloController.dispose()`. Abre y cierra el diálogo varias veces y pega el aviso completo que aparece en la consola.

Después restaura el `dispose` y confirma que desaparece. Como con el desbordamiento de F01, provocar el aviso a propósito te enseña a reconocerlo cuando aparezca sin querer.

## Fuente · lee con una pregunta

Abre **State.dispose**. Dos preguntas: ¿en qué momento lo llama el framework?, ¿en qué orden debe llamarse a `super.dispose()`? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende quién debe crear el controller: el diálogo o quien lo abre.

Si lo crea el diálogo, la responsabilidad de liberarlo es suya y el código queda cerrado sobre sí mismo — a cambio, el texto se pierde en cada apertura. Si lo recibe por parámetro, el borrador puede sobrevivir, y ahora el dueño externo tiene que acordarse de liberarlo.

Elige y nombra quién queda responsable. Cierra el módulo:

```bash
cd flutter_lab
fvm flutter analyze
fvm flutter test
```

En F03 el estado deja de vivir en una pantalla y empieza a **viajar** entre rutas, con resultados y con gente que no usa el mouse.
