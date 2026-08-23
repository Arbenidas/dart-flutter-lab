import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/journal_entry.dart';
import '../journal_view_model.dart';

class JournalEditorDialog extends ConsumerStatefulWidget {
  const JournalEditorDialog({this.entry, super.key});

  final JournalEntry? entry;

  @override
  ConsumerState<JournalEditorDialog> createState() =>
      _JournalEditorDialogState();
}

class _JournalEditorDialogState extends ConsumerState<JournalEditorDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title);
    _bodyController = TextEditingController(text: widget.entry?.body);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.entry != null;
    return Dialog(
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: AppColors.ink, width: 3),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                editing ? 'EDITAR ENTRADA' : 'NUEVA ENTRADA',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Describe una decisión, una duda o algo que aprendiste.',
              ),
              const SizedBox(height: 22),
              TextField(
                key: const Key('journal-title-field'),
                controller: _titleController,
                autofocus: true,
                maxLength: 80,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Título'),
                onChanged: (_) => _clearError(),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('journal-body-field'),
                controller: _bodyController,
                minLines: 5,
                maxLines: 10,
                decoration: const InputDecoration(labelText: 'Nota'),
                onChanged: (_) => _clearError(),
              ),
              if (_error != null) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  key: const Key('journal-validation-error'),
                  style: const TextStyle(
                    color: Color(0xFF9E1B0C),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
              const SizedBox(height: 22),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  FilledButton.icon(
                    key: const Key('save-entry-button'),
                    onPressed: _save,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(editing ? 'Guardar cambios' : 'Crear entrada'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearError() {
    if (_error == null) {
      return;
    }
    ref.read(journalViewModelProvider.notifier).clearValidationError();
    setState(() => _error = null);
  }

  void _save() {
    final viewModel = ref.read(journalViewModelProvider.notifier);
    final entry = widget.entry;
    final saved = entry == null
        ? viewModel.createEntry(
            title: _titleController.text,
            body: _bodyController.text,
          )
        : viewModel.updateEntry(
            id: entry.id,
            title: _titleController.text,
            body: _bodyController.text,
          );
    if (saved) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _error = ref.read(journalViewModelProvider).validationError;
    });
  }
}
