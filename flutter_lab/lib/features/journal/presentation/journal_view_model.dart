import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/in_memory_journal_repository.dart';
import '../data/journal_repository.dart';
import 'journal_state.dart';

final journalRepositoryProvider = Provider<JournalRepository>(
  (ref) => InMemoryJournalRepository(),
);

final journalViewModelProvider =
    NotifierProvider<JournalViewModel, JournalState>(JournalViewModel.new);

class JournalViewModel extends Notifier<JournalState> {
  late JournalRepository _repository;

  @override
  JournalState build() {
    _repository = ref.watch(journalRepositoryProvider);
    return JournalState(entries: _repository.getAll());
  }

  bool createEntry({required String title, required String body}) {
    final normalizedTitle = title.trim();
    if (!_validateTitle(normalizedTitle)) {
      return false;
    }
    _repository.create(title: normalizedTitle, body: body.trim());
    _reload();
    return true;
  }

  bool updateEntry({
    required String id,
    required String title,
    required String body,
  }) {
    final normalizedTitle = title.trim();
    if (!_validateTitle(normalizedTitle)) {
      return false;
    }
    _repository.update(id: id, title: normalizedTitle, body: body.trim());
    _reload();
    return true;
  }

  void deleteEntry(String id) {
    _repository.delete(id);
    _reload();
  }

  void clearValidationError() {
    if (state.validationError != null) {
      state = state.copyWith(clearValidationError: true);
    }
  }

  bool _validateTitle(String title) {
    if (title.isEmpty) {
      state = state.copyWith(
        validationError: 'Ponle un título antes de guardarla.',
      );
      return false;
    }
    if (title.length > 80) {
      state = state.copyWith(
        validationError: 'El título debe tener 80 caracteres o menos.',
      );
      return false;
    }
    return true;
  }

  void _reload() {
    state = JournalState(entries: _repository.getAll());
  }
}
