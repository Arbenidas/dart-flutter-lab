import 'journal_repository.dart';
import 'models/journal_entry.dart';

typedef JournalClock = DateTime Function();

class InMemoryJournalRepository implements JournalRepository {
  InMemoryJournalRepository({JournalClock? clock})
    : _clock = clock ?? DateTime.now;

  final JournalClock _clock;
  final Map<String, JournalEntry> _entries = <String, JournalEntry>{};
  var _nextId = 1;

  @override
  List<JournalEntry> getAll() {
    final entries = _entries.values.toList()
      ..sort((a, b) {
        final byDate = b.updatedAt.compareTo(a.updatedAt);
        return byDate != 0 ? byDate : b.id.compareTo(a.id);
      });
    return List<JournalEntry>.unmodifiable(entries);
  }

  @override
  JournalEntry create({required String title, required String body}) {
    final now = _clock();
    final entry = JournalEntry(
      id: 'entry_${_nextId++}',
      title: title,
      body: body,
      createdAt: now,
      updatedAt: now,
    );
    _entries[entry.id] = entry;
    return entry;
  }

  @override
  JournalEntry update({
    required String id,
    required String title,
    required String body,
  }) {
    final current = _entries[id];
    if (current == null) {
      throw StateError('No existe una entrada con id $id.');
    }
    final updated = current.copyWith(
      title: title,
      body: body,
      updatedAt: _clock(),
    );
    _entries[id] = updated;
    return updated;
  }

  @override
  void delete(String id) {
    if (_entries.remove(id) == null) {
      throw StateError('No existe una entrada con id $id.');
    }
  }
}
