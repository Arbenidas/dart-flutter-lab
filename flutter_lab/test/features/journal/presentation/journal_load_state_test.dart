import 'package:flutter_lab/features/journal/data/async_journal_repository.dart';
import 'package:flutter_lab/features/journal/data/models/journal_entry.dart';
import 'package:flutter_lab/features/journal/presentation/journal_load_state.dart';
import 'package:flutter_test/flutter_test.dart';

JournalEntry _entry(String id) => JournalEntry(
  id: id,
  title: id,
  body: '',
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

void main() {
  group('F04-1 estados mutuamente excluyentes', () {
    test('una lista con datos produce JournalData', () {
      expect(stateFromResult(<JournalEntry>[_entry('a')]), isA<JournalData>());
    });

    test('una lista vacia produce JournalEmpty, no JournalData', () {
      expect(stateFromResult(<JournalEntry>[]), isA<JournalEmpty>());
    });

    test('cada estado ofrece la accion que corresponde', () {
      expect(actionFor(const JournalLoading()), isNull);
      expect(actionFor(const JournalEmpty()), 'Crear la primera entrada');
      expect(actionFor(const JournalFailure('x')), 'Reintentar');
    });
  });

  group('F04-2 el repositorio falso cubre los caminos', () {
    test('devuelve las entradas configuradas', () async {
      final repository = FakeAsyncJournalRepository(
        entries: <JournalEntry>[_entry('a')],
      );
      expect(await repository.fetchAll(), hasLength(1));
    });

    test('lanza cuando se configura un fallo', () {
      final repository = FakeAsyncJournalRepository(failure: 'sin red');
      expect(repository.fetchAll(), throwsStateError);
    });
  });

  group('F04-3 JournalLoader traduce el resultado a un estado', () {
    test('empieza cargando', () {
      expect(JournalLoader(FakeAsyncJournalRepository()).state, isA<JournalLoading>());
    });

    test('termina en vacio cuando no hay entradas', () async {
      final loader = JournalLoader(FakeAsyncJournalRepository());
      await loader.load();
      expect(loader.state, isA<JournalEmpty>());
    });

    test('termina en datos cuando hay entradas', () async {
      final loader = JournalLoader(
        FakeAsyncJournalRepository(entries: <JournalEntry>[_entry('a')]),
      );
      await loader.load();
      expect(loader.state, isA<JournalData>());
    });

    test('termina en fallo sin filtrar el error tecnico', () async {
      final loader = JournalLoader(
        FakeAsyncJournalRepository(failure: 'socket 111 en 10.0.0.3'),
      );
      await loader.load();
      expect(loader.state, isA<JournalFailure>());
      expect((loader.state as JournalFailure).message, isNot(contains('socket')));
    });
  });

  group('F04-4 gana la ultima carga pedida', () {
    test('una respuesta lenta anterior no pisa a una rapida posterior', () async {
      final lenta = FakeAsyncJournalRepository(
        entries: <JournalEntry>[_entry('vieja')],
        delay: const Duration(milliseconds: 40),
      );
      final loader = JournalLoader(lenta);
      final primera = loader.load();

      final rapida = JournalLoader(
        FakeAsyncJournalRepository(entries: <JournalEntry>[_entry('nueva')]),
      );
      await rapida.load();

      await primera;
      expect((loader.state as JournalData).entries.single.id, 'vieja');
      expect((rapida.state as JournalData).entries.single.id, 'nueva');
    });

    test('dos cargas seguidas sobre el mismo loader dejan solo la ultima', () async {
      final loader = JournalLoader(
        FakeAsyncJournalRepository(
          entries: <JournalEntry>[_entry('a')],
          delay: const Duration(milliseconds: 30),
        ),
      );
      final primera = loader.load();
      final segunda = loader.load();
      await Future.wait(<Future<void>>[primera, segunda]);
      expect(loader.state, isA<JournalData>());
    });
  });
}
