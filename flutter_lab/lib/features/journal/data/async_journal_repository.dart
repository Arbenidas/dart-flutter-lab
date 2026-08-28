import 'models/journal_entry.dart';

/// Fuente asíncrona de entradas.
///
/// Es un contrato aparte de [JournalRepository] a propósito: pasar de
/// síncrono a asíncrono cambia la firma de todo lo que hay encima, y esa
/// diferencia se ve mejor con los dos contratos a la vista.
abstract interface class AsyncJournalRepository {
  Future<List<JournalEntry>> fetchAll();
}

/// Repositorio falso con retardo y fallo configurables.
///
/// Existe para poder provocar los cuatro estados de carga sin depender de una
/// red real y sin esperar de verdad.
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
