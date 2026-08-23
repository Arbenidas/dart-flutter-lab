import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_lab/app.dart';
import 'package:flutter_lab/features/journal/data/in_memory_journal_repository.dart';
import 'package:flutter_lab/features/journal/presentation/journal_view_model.dart';
import 'package:flutter/widgets.dart';

void main() {
  testWidgets('permite crear, editar y eliminar una entrada', (tester) async {
    final repository = InMemoryJournalRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [journalRepositoryProvider.overrideWithValue(repository)],
        child: const FlutterLabApp(),
      ),
    );

    expect(find.byKey(const Key('empty-journal-state')), findsOneWidget);

    await tester.tap(find.byKey(const Key('new-entry-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('journal-title-field')),
      'Mi primera entrada',
    );
    await tester.enterText(
      find.byKey(const Key('journal-body-field')),
      'Aprendí a separar la vista del repositorio.',
    );
    await tester.tap(find.byKey(const Key('save-entry-button')));
    await tester.pumpAndSettle();

    expect(find.text('Mi primera entrada'), findsOneWidget);
    expect(find.textContaining('Aprendí a separar'), findsOneWidget);
    expect(find.text('1 ENTRADA'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('edit-entry-entry_1')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('journal-title-field')),
      'Entrada editada',
    );
    await tester.tap(find.byKey(const Key('save-entry-button')));
    await tester.pumpAndSettle();
    expect(find.text('Entrada editada'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('delete-entry-entry_1')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-delete-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('empty-journal-state')), findsOneWidget);
    expect(find.text('0 ENTRADAS'), findsOneWidget);
  });

  testWidgets('muestra la validación del ViewModel', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          journalRepositoryProvider.overrideWithValue(
            InMemoryJournalRepository(),
          ),
        ],
        child: const FlutterLabApp(),
      ),
    );

    await tester.tap(find.byKey(const Key('new-entry-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-entry-button')));
    await tester.pump();

    expect(find.byKey(const Key('journal-validation-error')), findsOneWidget);
  });
}
