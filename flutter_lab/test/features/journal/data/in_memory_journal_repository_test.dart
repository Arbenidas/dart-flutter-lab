import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_lab/features/journal/data/in_memory_journal_repository.dart';

void main() {
  test('crea, actualiza y elimina entradas', () {
    var now = DateTime(2026, 8, 23, 10);
    final repository = InMemoryJournalRepository(
      clock: () {
        final value = now;
        now = now.add(const Duration(minutes: 1));
        return value;
      },
    );

    expect(repository.getAll(), isEmpty);

    final created = repository.create(title: 'Hipótesis', body: 'Primera');
    expect(created.id, 'entry_1');
    expect(repository.getAll(), <Object>[created]);

    final updated = repository.update(
      id: created.id,
      title: 'Hipótesis corregida',
      body: 'Segunda',
    );
    expect(updated.createdAt, created.createdAt);
    expect(updated.updatedAt.isAfter(created.updatedAt), isTrue);
    expect(repository.getAll().single.title, 'Hipótesis corregida');

    repository.delete(created.id);
    expect(repository.getAll(), isEmpty);
  });

  test('actualizar o eliminar un id inexistente falla de forma explícita', () {
    final repository = InMemoryJournalRepository();

    expect(
      () => repository.update(id: 'missing', title: 'x', body: 'y'),
      throwsStateError,
    );
    expect(() => repository.delete('missing'), throwsStateError);
  });
}
