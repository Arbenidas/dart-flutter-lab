---
id: 'F04-L02'
trackId: 'flutter'
moduleId: 'F04'
kind: 'taller'
order: 1
slug: 'un-repositorio-asincrono-sustituible'
title: 'Provocar el fallo en vez de esperarlo'
summary: 'Escribe una fuente asíncrona falsa con retardo y error configurables para poder recorrer los cuatro estados a voluntad.'
estimatedMinutes: 50
objectives:
  - 'Declarar un contrato asíncrono y una implementación falsa configurable.'
  - 'Provocar un fallo y un retardo sin depender de una red real.'
  - 'Explicar por qué el contrato asíncrono se declara aparte del síncrono.'
prerequisites: ['F04-L01']
activities:
  - id: 'predecir-doble-async'
    kind: 'attempt'
    prompt: 'Sin abrir el código, escribe qué necesitarías configurar en una fuente falsa para poder probar los cuatro estados de la pantalla.'
    required: true
    hints:
      - 'Necesitas controlar qué devuelve, cuánto tarda y si falla.'
      - 'Sin control del retardo no se puede probar una carrera entre respuestas.'
  - id: 'probar-fallo'
    kind: 'evidence'
    prompt: 'Revisa FakeAsyncJournalRepository, ejecuta las pruebas del archivo y pega la salida del caso configurado para fallar.'
    required: true
    hints:
      - 'El fallo se declara en el constructor, no se provoca por accidente.'
      - 'El retardo cero sigue siendo asíncrono.'
  - id: 'sustentar-fetch'
    kind: 'source'
    prompt: 'En Fetch data from the internet, encuentra qué recomienda sobre separar la obtención de datos de la interfaz.'
    required: true
    sourceLabel: 'Fetch data from the internet'
    hints:
      - 'Busca dónde ubica la llamada de red en el ejemplo.'
      - 'Anota el encabezado y una frase.'
  - id: 'defender-contrato-aparte'
    kind: 'judgment'
    prompt: 'Decide si el contrato asíncrono debería reemplazar al síncrono o convivir con él, y nombra qué cambia para todas las capas de arriba.'
    required: true
    hints:
      - 'Pasar de List<T> a Future<List<T>> cambia la firma de todo lo que lo consume.'
      - 'Convivir duplica el contrato y evita migrar de golpe.'
docRefs:
  - label: 'Fetch data from the internet'
    url: 'https://docs.flutter.dev/cookbook/networking/fetch-data'
    kind: 'cookbook'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Testing Flutter apps'
    url: 'https://docs.flutter.dev/testing/overview'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué hace falta configurar en un doble para poder recorrer los cuatro estados?'
  - 'En un archivo vacío, vuelve a escribir un repositorio falso con retardo y fallo, sin mirar la lección.'
  - 'Explica en voz alta por qué pasar de síncrono a asíncrono cambia todas las capas de arriba.'
  - 'Escribe un doble para otra fuente de datos y define qué le harías configurable.'
lab:
  workspace: 'flutter_lab'
  targetPath: 'lib/features/journal/data/async_journal_repository.dart'
  testCommand: 'fvm flutter test test/features/journal/presentation/journal_load_state_test.dart'
  analyzeCommand: 'fvm flutter analyze'
---

Para probar el estado de error hace falta un error. Esperar a que la red se caiga no es un plan.

## El contrato asíncrono

```dart
abstract interface class AsyncJournalRepository {
  Future<List<JournalEntry>> fetchAll();
}
```

Está declarado **aparte** de `JournalRepository`, el síncrono que usaste en F05 y F06. No es duplicación descuidada: tener los dos a la vista hace visible lo que cambia al pasar de uno a otro.

`List<JournalEntry>` y `Future<List<JournalEntry>>` son tipos distintos. Cambiar el primero por el segundo obliga a modificar la firma de **todo** lo que lo consume, hacia arriba, hasta la pantalla. Ese es el efecto dominó que hace caro migrar tarde.

## El doble configurable

```dart
class FakeAsyncJournalRepository implements AsyncJournalRepository {
  FakeAsyncJournalRepository({
    this.entries = const <JournalEntry>[],
    this.delay = Duration.zero,
    this.failure,
  });

  final List<JournalEntry> entries;
  final Duration delay;
  final String? failure;

  @override
  Future<List<JournalEntry>> fetchAll() async {
    await Future<void>.delayed(delay);
    final message = failure;
    if (message != null) {
      throw StateError(message);
    }
    return entries;
  }
}
```

Tres perillas, y cada una habilita un tipo de prueba:

| Perilla   | Qué permite probar                    |
| --------- | ------------------------------------- |
| `entries` | el estado con datos y el vacío        |
| `failure` | el estado de error                    |
| `delay`   | el orden de respuestas y las carreras |

Sin la tercera, la lección F04-L04 sería imposible de escribir.

## El retardo cero sigue siendo asíncrono

`Duration.zero` no vuelve síncrona la función: sigue cediendo el turno en el `await`, exactamente como viste en D10-L01. El doble es rápido y mantiene la asincronía real, que es justo lo que quieres probar.

## Intento · antes de mirar

Escribe qué configurarías en el doble para provocar cada uno de los cuatro estados de la pantalla. Uno de ellos no se puede provocar solo con el doble: identifícalo.

## Evidencia · ejecuta y compara

```bash
cd flutter_lab
fvm flutter test test/features/journal/presentation/journal_load_state_test.dart
```

Pega la salida del caso configurado para fallar.

## Fuente · lee con una pregunta

Abre **Fetch data from the internet** con una pregunta concreta: ¿dónde ubica el ejemplo oficial la llamada de red respecto de la interfaz? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende tener los dos contratos conviviendo. Reemplazar el síncrono de golpe obligaría a migrar la app entera en un solo cambio; convivir permite migrar por partes y deja dos contratos que hacen casi lo mismo.

Elige y nombra el costo. En la próxima lección el resultado del repositorio se convierte en un estado.
