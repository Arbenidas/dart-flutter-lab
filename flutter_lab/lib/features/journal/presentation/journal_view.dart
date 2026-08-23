import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../data/models/journal_entry.dart';
import 'journal_view_model.dart';
import 'widgets/journal_editor_dialog.dart';
import 'widgets/journal_entry_card.dart';

class JournalView extends ConsumerWidget {
  const JournalView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(journalViewModelProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: CustomScrollView(
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                  sliver: SliverToBoxAdapter(
                    child: _Header(entryCount: state.entries.length),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: _Toolbar(onCreate: () => _openEditor(context)),
                  ),
                ),
                if (state.entries.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 26, 48),
                    sliver: SliverList.separated(
                      itemCount: state.entries.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 22),
                      itemBuilder: (context, index) {
                        final entry = state.entries[index];
                        return JournalEntryCard(
                          entry: entry,
                          onEdit: () => _openEditor(context, entry: entry),
                          onDelete: () => _confirmDelete(context, ref, entry),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, {JournalEntry? entry}) async {
    await showDialog<bool>(
      context: context,
      builder: (context) => JournalEditorDialog(entry: entry),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    JournalEntry entry,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar entrada?'),
        content: Text('“${entry.title}” desaparecerá de esta sesión.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            key: const Key('confirm-delete-button'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.coral),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      ref.read(journalViewModelProvider.notifier).deleteEntry(entry.id);
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.entryCount});

  final int entryCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        final title = Text(
          'BITÁCORA_01',
          style: Theme.of(
            context,
          ).textTheme.displayLarge?.copyWith(fontSize: compact ? 38 : 60),
        );
        final counter = Container(
          decoration: BoxDecoration(
            color: AppColors.acid,
            border: Border.all(color: AppColors.ink, width: 3),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            '$entryCount ${entryCount == 1 ? 'ENTRADA' : 'ENTRADAS'}',
            key: const Key('entry-count'),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (compact) ...<Widget>[
              title,
              const SizedBox(height: 16),
              counter,
            ] else
              Row(
                children: <Widget>[
                  Expanded(child: title),
                  counter,
                ],
              ),
            const SizedBox(height: 18),
            const Text(
              'Escribe lo que entendiste. Registra también lo que todavía no.',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ],
        );
      },
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.ink, width: 2),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: <Widget>[
          const Text(
            'MEMORIA LOCAL · SE BORRA AL RECARGAR',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          ),
          FilledButton.icon(
            key: const Key('new-entry-button'),
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Nueva entrada'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: Container(
          key: const Key('empty-journal-state'),
          constraints: const BoxConstraints(maxWidth: 620),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.ink, width: 3),
            boxShadow: const <BoxShadow>[
              BoxShadow(color: AppColors.ink, offset: Offset(7, 7)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.edit_note, size: 58),
              const SizedBox(height: 14),
              Text(
                'LA PÁGINA EN BLANCO ES PARTE DEL EJERCICIO.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Crea una entrada sobre la última decisión que tomaste al programar.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
