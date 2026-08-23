import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/journal_entry.dart';

class JournalEntryCard extends StatelessWidget {
  const JournalEntryCard({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final JournalEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Entrada ${entry.title}',
      child: Container(
        key: ValueKey<String>('entry-card-${entry.id}'),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.ink, width: 3),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: AppColors.ink, offset: Offset(6, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    entry.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  key: ValueKey<String>('edit-entry-${entry.id}'),
                  tooltip: 'Editar ${entry.title}',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  key: ValueKey<String>('delete-entry-${entry.id}'),
                  tooltip: 'Eliminar ${entry.title}',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            if (entry.body.isNotEmpty) ...<Widget>[
              const SizedBox(height: 10),
              Text(entry.body, maxLines: 5, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 18),
            Container(
              color: AppColors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              child: Text(
                'EDITADA ${_formatDate(entry.updatedAt)}',
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }
}
