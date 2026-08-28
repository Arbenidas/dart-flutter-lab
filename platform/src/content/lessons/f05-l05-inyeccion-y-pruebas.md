---
id: 'F05-L05'
trackId: 'flutter'
moduleId: 'F05'
kind: 'taller'
order: 4
slug: 'inyeccion-que-produce-pruebas-baratas'
title: 'Una dependencia sustituible vuelve barata la prueba'
summary: 'Sustituye el repositorio con un override de provider y comprueba el ViewModel sin montar interfaz ni esperar a nadie.'
estimatedMinutes: 60
objectives:
  - 'Sustituir una dependencia mediante un override de provider en una prueba.'
  - 'Explicar por qué depender de un contrato y no de una implementación abarata las pruebas.'
  - 'Controlar el tiempo inyectando un reloj en vez de usar el del sistema.'
prerequisites: ['F05-L04']
activities:
  - id: 'predecir-sustitucion'
    kind: 'attempt'
    prompt: 'Sin abrir las pruebas, escribe qué haría falta para probar el ViewModel sin usar el repositorio real, y qué garantiza que la sustitución sea válida.'
    required: true
    hints:
      - 'El ViewModel depende de un contrato, no de una clase concreta.'
      - 'Riverpod permite reemplazar lo que devuelve un provider.'
  - id: 'sustituir-repositorio'
    kind: 'evidence'
    prompt: 'En la prueba del ViewModel, sustituye el repositorio por uno con un reloj fijo mediante un override y ejecuta las pruebas. Pega la salida.'
    required: true
    hints:
      - 'InMemoryJournalRepository acepta un clock por constructor.'
      - 'El override se declara al crear el ProviderContainer de la prueba.'
  - id: 'sustentar-testing'
    kind: 'source'
    prompt: 'En Testing Flutter apps, encuentra qué distingue una prueba unitaria de una de widgets y cuál conviene para lógica sin interfaz.'
    required: true
    sourceLabel: 'Testing Flutter apps'
    hints:
      - 'Busca los tipos de prueba que enumera la página.'
      - 'Anota el encabezado y qué ejemplo da de cada uno.'
  - id: 'defender-reloj'
    kind: 'judgment'
    prompt: 'Decide si inyectar un reloj vale la pena en esta app y nombra qué prueba se vuelve imposible sin hacerlo.'
    required: true
    hints:
      - 'Una prueba que compara fechas con DateTime.now falla de forma intermitente.'
      - 'Inyectar el reloj agrega un parámetro a cada construcción del repositorio.'
docRefs:
  - label: 'Testing Flutter apps'
    url: 'https://docs.flutter.dev/testing/overview'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Common architecture concepts'
    url: 'https://docs.flutter.dev/app-architecture/concepts'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué vuelve sustituible y fácil de probar a una dependencia?'
  - 'En un archivo vacío, vuelve a escribir una prueba de ViewModel con el repositorio sustituido, sin mirar el original.'
  - 'Explica en voz alta por qué un reloj inyectado elimina pruebas intermitentes.'
  - 'Sustituye conceptualmente el repositorio en memoria por API más caché local y dibuja qué clases cambian.'
lab:
  workspace: 'flutter_lab'
  targetPath: 'test/features/journal/presentation/journal_view_model_test.dart'
  testCommand: 'fvm flutter test test/features/journal/presentation/journal_view_model_test.dart'
  analyzeCommand: 'fvm flutter analyze'
  revealReference: true
---

Todo lo anterior del módulo apunta aquí: si las capas están bien separadas, probar sale barato. Si no, cada prueba necesita levantar media aplicación.

## El contrato es lo que se sustituye

```dart
abstract interface class JournalRepository {
  List<JournalEntry> getAll();
  JournalEntry create({required String title, required String body});
  ...
}
```

El `ViewModel` no depende de `InMemoryJournalRepository`: depende de este contrato. Por eso se puede poner otra cosa detrás sin tocar el `ViewModel`.

En Riverpod, esa sustitución se hace con un override:

```dart
final container = ProviderContainer(
  overrides: <Override>[
    journalRepositoryProvider.overrideWithValue(
      InMemoryJournalRepository(clock: () => DateTime.utc(2026, 1, 1)),
    ),
  ],
);
addTearDown(container.dispose);
```

El `ViewModel` no se entera. Cree que está hablando con su repositorio de siempre.

## El reloj también es una dependencia

Fíjate en el `clock` del ejemplo:

```dart
typedef JournalClock = DateTime Function();

InMemoryJournalRepository({JournalClock? clock}) : _clock = clock ?? DateTime.now;
```

`DateTime.now` es una dependencia oculta: hace que el resultado dependa de **cuándo** se ejecuta la prueba. Una prueba que ordena entradas por fecha y las crea en el mismo milisegundo falla de vez en cuando, y eso es peor que fallar siempre.

Inyectar el reloj convierte el tiempo en un dato que controlas. Y fíjate en el tipo: `DateTime Function()` es exactamente lo que aprendiste a leer en D04-L01.

## Sin montar interfaz

Las pruebas del `ViewModel` no usan `WidgetTester` ni bombean frames. Crean un contenedor, leen el estado, llaman comandos y comprueban el estado nuevo. Son rápidas y no se rompen cuando alguien cambia un `Padding`.

Esa velocidad no es un premio: es la consecuencia directa de que el `ViewModel` no sepa nada de widgets.

## Intento · antes de mirar

Escribe, antes de abrir las pruebas, qué haría falta para probar `createEntry` sin el repositorio real. ¿Qué garantiza que tu sustituto sea válido?

## Evidencia · ejecuta y compara

En la prueba del `ViewModel`, sustituye el repositorio por uno con un reloj fijo mediante un override. Ejecuta:

```bash
cd flutter_lab
fvm flutter test test/features/journal/presentation/journal_view_model_test.dart
```

Pega la salida. Experimento: quita el reloj fijo, crea dos entradas seguidas y comprueba el orden. Repite la prueba varias veces y observa si el resultado es estable.

## Fuente · lee con una pregunta

Abre **Testing Flutter apps** y busca los tipos de prueba. Pregunta concreta: ¿cuál conviene para lógica sin interfaz? Anota el encabezado y el ejemplo que da.

## Criterio · decide y acepta el costo

Defiende el reloj inyectado. Sin él, la prueba de ordenamiento por fecha es intermitente, y una prueba intermitente termina desactivada. Con él, cada construcción del repositorio acepta un parámetro más que en producción nadie pasa.

Nombra qué prueba concreta se vuelve imposible sin la inyección. Cierra el módulo:

```bash
cd flutter_lab
fvm flutter analyze
fvm flutter test
```

En F06 juntas todo: el CRUD completo, probado en tres niveles.
