---
id: 'F04-L03'
trackId: 'flutter'
moduleId: 'F04'
kind: 'taller'
order: 2
slug: 'traducir-un-resultado-a-un-estado'
title: 'Traducir el resultado en un estado, y el error en un mensaje'
summary: 'Convierte la respuesta del repositorio en el estado que corresponde, sin filtrar el motivo técnico a la pantalla.'
estimatedMinutes: 55
objectives:
  - 'Convertir un resultado asíncrono en el estado de pantalla correspondiente.'
  - 'Traducir un error técnico a un mensaje seguro.'
  - 'Explicar por qué la traducción vive fuera del widget.'
prerequisites: ['F04-L02']
activities:
  - id: 'predecir-mensaje'
    kind: 'attempt'
    prompt: 'Sin abrir el código, escribe qué debería ver la persona cuando la carga falla con un error de socket que menciona una dirección interna.'
    required: true
    hints:
      - 'El mensaje de la pantalla y el del registro son dos textos distintos.'
      - 'Recuerda D09-L05.'
  - id: 'probar-traduccion'
    kind: 'evidence'
    prompt: 'Revisa JournalLoader.load, ejecuta las pruebas y pega la salida del test que comprueba que el mensaje no contiene el detalle técnico.'
    required: true
    hints:
      - 'El estado inicial es cargando, antes de llamar a load.'
      - 'El catch produce un mensaje fijo, no el texto del error.'
  - id: 'sustentar-estado-ui'
    kind: 'source'
    prompt: 'En UI layer case study, encuentra dónde ubica el ejemplo oficial la conversión de datos a estado de interfaz.'
    required: true
    sourceLabel: 'UI layer case study'
    hints:
      - 'Busca qué capa produce el estado que consume la vista.'
      - 'Anota el encabezado.'
  - id: 'defender-mensaje-fijo'
    kind: 'judgment'
    prompt: 'Decide entre un mensaje fijo y uno que varíe según el tipo de error, y nombra qué gana la persona y qué se arriesga.'
    required: true
    hints:
      - 'Un mensaje distinto por causa ayuda a saber si conviene reintentar.'
      - 'Cada mensaje nuevo es una oportunidad de filtrar algo interno.'
docRefs:
  - label: 'UI layer case study'
    url: 'https://docs.flutter.dev/app-architecture/case-study/ui-layer'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'FutureBuilder class'
    url: 'https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html'
    kind: 'api'
    version: 'API estable'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Dónde se transforma un resultado asíncrono en el estado que consume la vista?'
  - 'En un archivo vacío, vuelve a escribir la traducción de resultado a estado, sin mirar la lección.'
  - 'Explica en voz alta por qué el mensaje de la pantalla no es el del registro.'
  - 'Define los mensajes de una pantalla de sincronización y comprueba que ninguno filtra detalle interno.'
lab:
  workspace: 'flutter_lab'
  targetPath: 'lib/features/journal/presentation/journal_load_state.dart'
  testCommand: 'fvm flutter test test/features/journal/presentation/journal_load_state_test.dart'
  analyzeCommand: 'fvm flutter analyze'
---

El repositorio devuelve datos o lanza. La pantalla necesita uno de cuatro estados. Alguien tiene que traducir, y ese alguien no es el widget.

## La traducción

```dart
class JournalLoader {
  JournalLoader(this._repository);

  final AsyncJournalRepository _repository;

  JournalLoadState state = const JournalLoading();

  Future<void> load() async {
    state = const JournalLoading();
    try {
      final entries = await _repository.fetchAll();
      state = stateFromResult(entries);
    } catch (_) {
      state = const JournalFailure('No pudimos cargar la bitácora.');
    }
  }
}
```

Tres decisiones:

1. **El estado inicial es `JournalLoading`**, antes de que nadie llame a `load`. La pantalla nunca empieza en un estado indefinido.
2. **`stateFromResult` decide entre vacío y datos.** El loader no repite esa regla.
3. **El error se traduce a un mensaje fijo.**

## El mensaje no es el error

```dart
catch (_) {
  state = const JournalFailure('No pudimos cargar la bitácora.');
}
```

El `_` es deliberado: el error **no** se usa para construir el mensaje. Si lo hiciéramos, un `SocketException: OS Error: Connection refused, address = 10.0.0.3` terminaría en la pantalla del usuario.

Es exactamente la regla de D09-L05: el motivo técnico va al registro, el mensaje va a la pantalla. La prueba lo fija comprobando que el mensaje **no contiene** el texto técnico.

## Fuera del widget

Toda esta lógica vive en una clase normal de Dart. Ningún `import` de Flutter, ningún `BuildContext`.

Eso permite probarla sin montar nada —como el `ViewModel` de F05-L05— y permite reutilizarla. Un widget que hiciera `try/catch` dentro de su `build` mezclaría dos responsabilidades y sería imposible de probar sin `WidgetTester`.

## Intento · antes de mirar

Escribe qué debería ver la persona cuando la carga falla con un error que menciona una dirección interna, y qué debería quedar en el registro.

## Evidencia · ejecuta y compara

```bash
cd flutter_lab
fvm flutter test test/features/journal/presentation/journal_load_state_test.dart
```

Pega la salida del test que comprueba que el mensaje no filtra el detalle técnico.

## Fuente · lee con una pregunta

Abre **UI layer case study** con una pregunta concreta: ¿qué capa produce el estado que consume la vista? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende el mensaje fijo. Un mensaje distinto según la causa —«sin conexión» frente a «el servidor no responde»— ayuda a la persona a saber si conviene reintentar ahora o más tarde.

A cambio, cada mensaje nuevo es una decisión más y una oportunidad más de filtrar algo. Elige y nombra el costo. En la última lección aparece el fallo que solo ocurre cuando dos cargas se cruzan.
