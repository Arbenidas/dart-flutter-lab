import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_lab/features/journal/data/in_memory_journal_repository.dart';
import 'package:flutter_lab/features/journal/presentation/journal_view_model.dart';

void main() {
  test('el ViewModel ejecuta el CRUD a través del repositorio', () {
    final repository = InMemoryJournalRepository();
    final container = ProviderContainer(
      overrides: [journalRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final viewModel = container.read(journalViewModelProvider.notifier);

    expect(
      viewModel.createEntry(title: '  Aprendizaje  ', body: '  Nota  '),
      isTrue,
    );
    var state = container.read(journalViewModelProvider);
    expect(state.entries.single.title, 'Aprendizaje');
    expect(state.entries.single.body, 'Nota');

    final id = state.entries.single.id;
    expect(
      viewModel.updateEntry(id: id, title: 'Refactor', body: 'Separé capas'),
      isTrue,
    );
    state = container.read(journalViewModelProvider);
    expect(state.entries.single.title, 'Refactor');

    viewModel.deleteEntry(id);
    expect(container.read(journalViewModelProvider).entries, isEmpty);
  });

  test('rechaza títulos vacíos sin escribir en el repositorio', () {
    final repository = InMemoryJournalRepository();
    final container = ProviderContainer(
      overrides: [journalRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final viewModel = container.read(journalViewModelProvider.notifier);

    expect(viewModel.createEntry(title: '   ', body: 'sin título'), isFalse);
    expect(container.read(journalViewModelProvider).entries, isEmpty);
    expect(
      container.read(journalViewModelProvider).validationError,
      isNotEmpty,
    );
  });
}
