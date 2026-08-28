---
id: 'F06-L03'
trackId: 'flutter'
moduleId: 'F06'
kind: 'taller'
order: 2
slug: 'probar-el-repositorio-en-aislamiento'
title: 'Probar el repositorio en aislamiento'
summary: 'Escribe pruebas de datos que fijen el contrato, incluidos los fallos, sin montar nada de interfaz.'
estimatedMinutes: 60
objectives:
  - 'Escribir una prueba unitaria con arrange, act y assert sobre el repositorio.'
  - 'Cubrir el caso de fallo además del caso feliz.'
  - 'Explicar por qué una lista no modificable es parte del contrato.'
prerequisites: ['F06-L02']
activities:
  - id: 'predecir-contrato'
    kind: 'attempt'
    prompt: 'Sin abrir las pruebas, escribe qué debería ocurrir al actualizar o eliminar una entrada con un id inexistente, y qué devuelve getAll tras eliminar la última.'
    required: true
    hints:
      - 'El repositorio lanza en vez de ignorar la petición.'
      - 'Una lista vacía y una lista con basura son resultados muy distintos.'
  - id: 'agregar-prueba'
    kind: 'evidence'
    prompt: 'Agrega una prueba que compruebe que getAll devuelve una lista no modificable, ejecuta el archivo de pruebas del repositorio y pega la salida.'
    required: true
    hints:
      - 'Intentar agregar a la lista devuelta debe lanzar.'
      - 'Usa un matcher que espere una excepción.'
  - id: 'sustentar-unit'
    kind: 'source'
    prompt: 'En Testing Flutter apps, encuentra qué caracteriza a una prueba unitaria y qué ejemplo da de lo que conviene probar así.'
    required: true
    sourceLabel: 'Testing Flutter apps'
    hints:
      - 'Busca la sección de unit tests.'
      - 'Anota el encabezado y una frase.'
  - id: 'defender-lanzar'
    kind: 'judgment'
    prompt: 'Decide si eliminar un id inexistente debe lanzar o no hacer nada, y nombra qué error del llamador se vuelve invisible con cada opción.'
    required: true
    hints:
      - 'Lanzar convierte un bug del llamador en un fallo temprano.'
      - 'No hacer nada vuelve idempotente la operación y esconde el error.'
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
  - '¿Qué limitaciones funcionales tiene InMemoryJournalRepository?'
  - 'En un archivo vacío, vuelve a escribir una prueba de repositorio con arrange, act y assert, sin mirar el original.'
  - 'Explica en voz alta por qué devolver una lista no modificable forma parte del contrato.'
  - 'Escribe la prueba del caso de fallo de una operación de otro proyecto antes de escribir su caso feliz.'
lab:
  workspace: 'flutter_lab'
  targetPath: 'test/features/journal/data/in_memory_journal_repository_test.dart'
  testCommand: 'fvm flutter test test/features/journal/data/in_memory_journal_repository_test.dart'
  analyzeCommand: 'fvm flutter analyze'
---

La capa de datos es la más barata de probar y la que más gente deja sin pruebas, porque «solo guarda cosas».

## Arrange, act, assert

```dart
test('create agrega una entrada recuperable', () {
  // arrange
  final repository = InMemoryJournalRepository(clock: () => DateTime.utc(2026, 1, 1));

  // act
  final creada = repository.create(title: 'Primera', body: 'Cuerpo');

  // assert
  expect(repository.getAll(), <JournalEntry>[creada]);
});
```

Tres bloques con tres trabajos. Cuando una prueba mezcla los tres, cuesta saber qué se estaba comprobando al leer el fallo.

## Probar el fallo, no solo el éxito

El contrato de la bitácora dice que actualizar o eliminar un id inexistente **lanza**:

```dart
test('delete rechaza un id inexistente', () {
  final repository = InMemoryJournalRepository();
  expect(() => repository.delete('no-existe'), throwsStateError);
});
```

Esta prueba vale más que la del caso feliz. El caso feliz se descubre en el primer minuto de uso manual; el fallo se descubre en producción.

## La lista no modificable es parte del contrato

```dart
return List<JournalEntry>.unmodifiable(entries);
```

Esto no es una precaución interna: es una **promesa pública**. Quien recibe la lista no puede alterarla y, por tanto, no puede corromper el estado del repositorio a distancia. Como toda promesa pública, merece una prueba que la fije:

```dart
test('getAll devuelve una lista no modificable', () {
  final repository = InMemoryJournalRepository();
  repository.create(title: 'A', body: '');
  expect(() => repository.getAll().add(...), throwsUnsupportedError);
});
```

Es el mismo comportamiento que provocaste a mano en D01-L05, ahora fijado por una prueba.

## Intento · antes de mirar

Escribe, antes de abrir el archivo de pruebas:

- qué ocurre al actualizar un id inexistente
- qué ocurre al eliminar un id inexistente
- qué devuelve `getAll` después de eliminar la última entrada

## Evidencia · ejecuta y compara

Agrega la prueba de la lista no modificable y ejecuta:

```bash
cd flutter_lab
fvm flutter test test/features/journal/data/in_memory_journal_repository_test.dart
```

Pega la salida. Después haz el experimento inverso: quita el `unmodifiable` del repositorio y comprueba que tu prueba nueva se pone roja. Una prueba que no falla cuando rompes el código no está probando nada.

## Fuente · lee con una pregunta

Abre **Testing Flutter apps** y busca la sección de pruebas unitarias. Pregunta concreta: ¿qué ejemplo da de lo que conviene probar así? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende que `delete` lance ante un id inexistente. Lanzar convierte un bug del llamador en un fallo inmediato y ruidoso; no hacer nada vuelve la operación idempotente —cómodo si hay reintentos— y esconde para siempre que alguien está borrando cosas que no existen.

Elige y nombra qué error se vuelve invisible con tu opción. En la próxima lección subes una capa.
