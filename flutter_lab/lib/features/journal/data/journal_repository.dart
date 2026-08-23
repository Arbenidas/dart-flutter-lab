import 'models/journal_entry.dart';

abstract interface class JournalRepository {
  List<JournalEntry> getAll();

  JournalEntry create({required String title, required String body});

  JournalEntry update({
    required String id,
    required String title,
    required String body,
  });

  void delete(String id);
}
