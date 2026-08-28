---
id: 'F04-L04'
trackId: 'flutter'
moduleId: 'F04'
kind: 'taller'
order: 3
slug: 'gana-la-ultima-carga-pedida'
title: 'Gana la última pedida, no la última en llegar'
summary: 'Provoca la carrera entre dos cargas y descarta las respuestas obsoletas con un contador de peticiones.'
estimatedMinutes: 55
objectives:
  - 'Reconocer la carrera entre una respuesta lenta anterior y una rápida posterior.'
  - 'Descartar respuestas obsoletas con un identificador de petición.'
  - 'Provocar la carrera de forma determinista en una prueba.'
prerequisites: ['F04-L03']
activities:
  - id: 'predecir-carrera'
    kind: 'attempt'
    prompt: 'Sin abrir el código, predice qué muestra la pantalla si se piden dos cargas seguidas, la primera tarda 800 ms y la segunda 200 ms, y no hay ningún control.'
    required: true
    hints:
      - 'La respuesta lenta llega después y pisa a la rápida.'
      - 'El usuario ve el resultado de la búsqueda anterior.'
  - id: 'probar-carrera'
    kind: 'evidence'
    prompt: 'Revisa el contador de peticiones de JournalLoader, ejecuta las pruebas y pega la salida del test de las dos cargas seguidas.'
    required: true
    hints:
      - 'Cada carga toma un número al empezar y lo compara al terminar.'
      - 'Una respuesta obsoleta se descarta sin tocar el estado.'
  - id: 'sustentar-async-ui'
    kind: 'source'
    prompt: 'En FutureBuilder class, encuentra qué advierte sobre crear el Future dentro de build y qué problema causa.'
    required: true
    sourceLabel: 'FutureBuilder class'
    hints:
      - 'Busca la advertencia sobre construir el future en cada reconstrucción.'
      - 'Anota el encabezado.'
  - id: 'defender-descartar'
    kind: 'judgment'
    prompt: 'Decide entre descartar la respuesta obsoleta y cancelar la petición anterior, y nombra qué se sigue gastando con tu elección.'
    required: true
    hints:
      - 'Descartar es simple y el trabajo del servidor ya se hizo igual.'
      - 'Cancelar de verdad exige soporte del cliente y complica el código.'
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
  - '¿Por qué no debes crear el Future de una petición dentro de build?'
  - 'En un archivo vacío, vuelve a escribir el control de peticiones obsoletas, sin mirar la lección.'
  - 'Explica en voz alta cómo se provoca de forma determinista una carrera entre dos respuestas.'
  - 'Diseña una lectura offline-first: qué se muestra con caché antigua, qué ocurre al sincronizar y qué indicador evita confundir guardado local con sincronizado.'
lab:
  workspace: 'flutter_lab'
  targetPath: 'lib/features/journal/presentation/journal_load_state.dart'
  testCommand: 'fvm flutter test test/features/journal/presentation/journal_load_state_test.dart'
  analyzeCommand: 'fvm flutter analyze'
  revealReference: true
---

Este es el bug asíncrono que más veces llega a producción, porque no aparece nunca mientras desarrollas con una red rápida.

## La carrera

Una persona escribe en un buscador. Cada tecla dispara una carga.

1. Pide «da» → el servidor tarda 800 ms.
2. Pide «dart» → el servidor tarda 200 ms.
3. A los 200 ms llegan los resultados de «dart». La pantalla los muestra. Correcto.
4. A los 800 ms llegan los de «da». La pantalla **los muestra**.

El usuario escribió «dart» y está viendo los resultados de «da». Nada falló, ninguna excepción se lanzó, y el estado es incorrecto.

Ganó la última en **llegar**, no la última en **pedirse**.

## El contador de peticiones

```dart
int _requestId = 0;

Future<void> load() async {
  final id = ++_requestId;
  state = const JournalLoading();
  try {
    final entries = await _repository.fetchAll();
    if (id != _requestId) {
      return;                // llegó tarde: ya hay una petición más nueva
    }
    state = stateFromResult(entries);
  } catch (_) {
    if (id != _requestId) {
      return;
    }
    state = const JournalFailure('No pudimos cargar la bitácora.');
  }
}
```

Cada carga toma un número al empezar y lo compara al terminar. Si `_requestId` cambió, hubo una petición posterior y esta respuesta es obsoleta: **se descarta sin tocar el estado**.

Fíjate en que la comprobación está en las **dos** ramas. Un error obsoleto que pise un resultado bueno es igual de malo.

## Por qué no crear el Future en build

`build` puede ejecutarse muchas veces. Crear ahí el `Future` de una petición dispara una carga en cada reconstrucción, y todas compiten entre sí — la carrera de arriba, multiplicada.

Por eso la carga se dispara en `initState`, en un `ViewModel` o en un loader como este: en un sitio que se ejecuta cuando **tú** decides.

## Provocar la carrera a propósito

```dart
final lenta = FakeAsyncJournalRepository(
  entries: <JournalEntry>[_entry('vieja')],
  delay: const Duration(milliseconds: 40),
);
```

Aquí es donde la perilla `delay` de F04-L02 se paga sola. Sin control del retardo, esta prueba dependería de la suerte; con él, la carrera ocurre siempre igual.

## Intento · antes de mirar

Escribe la secuencia completa del ejemplo del buscador con tiempos de 800 y 200 ms, marcando qué muestra la pantalla en cada instante, sin ningún control.

## Evidencia · ejecuta y compara

```bash
cd flutter_lab
fvm flutter test test/features/journal/presentation/journal_load_state_test.dart
```

Pega la salida del test de las dos cargas seguidas. Experimento: quita las dos comprobaciones de `id != _requestId` y observa qué test se rompe.

## Fuente · lee con una pregunta

Abre **FutureBuilder class** con una pregunta concreta: ¿qué advierte sobre crear el `Future` dentro de `build`? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende descartar frente a cancelar de verdad la petición anterior.

Descartar es simple y sigue gastando: el servidor hizo el trabajo, los bytes viajaron, la batería se usó. Cancelar ahorra todo eso y exige soporte del cliente HTTP y más código.

Elige y nombra lo que sigues gastando. Cierra el módulo:

```bash
cd flutter_lab
fvm flutter analyze
fvm flutter test
```

En F05 este estado deja de vivir en una clase suelta y pasa a una arquitectura completa.
