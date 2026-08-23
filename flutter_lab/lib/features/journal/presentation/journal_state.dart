import '../data/models/journal_entry.dart';

class JournalState {
  const JournalState({
    this.entries = const <JournalEntry>[],
    this.validationError,
  });

  final List<JournalEntry> entries;
  final String? validationError;

  JournalState copyWith({
    List<JournalEntry>? entries,
    String? validationError,
    bool clearValidationError = false,
  }) {
    return JournalState(
      entries: entries ?? this.entries,
      validationError: clearValidationError
          ? null
          : validationError ?? this.validationError,
    );
  }
}
