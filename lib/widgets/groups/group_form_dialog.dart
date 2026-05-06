import 'package:flutter/material.dart';

import '../../data/datasources/team_group_local_datasource.dart';
import '../../data/models/team_group_model.dart';

class GroupFormDialog extends StatefulWidget {
  const GroupFormDialog({
    super.key,
    required this.onSave,
    this.initialGroup,
    this.title,
  });

  final Future<void> Function(TeamGroupModel group) onSave;
  final TeamGroupModel? initialGroup;
  final String? title;

  @override
  State<GroupFormDialog> createState() => _GroupFormDialogState();
}

class _GroupFormDialogState extends State<GroupFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  bool _isSaving = false;

  bool get _isEditing => widget.initialGroup != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialGroup?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final existing = widget.initialGroup;
    final group = TeamGroupModel(
      id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      createdAt: existing?.createdAt ?? DateTime.now(),
    );

    try {
      await widget.onSave(group);
      if (!mounted) return;
      Navigator.of(context).pop(group);
    } on TeamGroupValidationException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nao foi possivel salvar o grupo.')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isSaving = false);
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o nome';
    }

    if (value.trim().length < 2) {
      return 'Nome muito curto';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title ?? (_isEditing ? 'Editar grupo' : 'Criar grupo')),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nome do grupo',
          ),
          validator: _validateName,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _save(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: Text(_isEditing ? 'Salvar' : 'Criar grupo'),
        ),
      ],
    );
  }
}
