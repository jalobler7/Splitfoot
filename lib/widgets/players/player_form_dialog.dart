import 'package:flutter/material.dart';
import '../../../data/models/player_model.dart';

class PlayerFormDialog extends StatefulWidget {
  final void Function(PlayerModel player) onSave;

  const PlayerFormDialog({
    super.key,
    required this.onSave,
  });

  @override
  State<PlayerFormDialog> createState() => _PlayerFormDialogState();
}

class _PlayerFormDialogState extends State<PlayerFormDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _attackController = TextEditingController();
  final _defenseController = TextEditingController();
  final _staminaController = TextEditingController();

  String _selectedPosition = 'Ala';

  final List<String> _positions = [
    'Pivo',
    'Ala',
    'Fixo',
    'Meia',
    'Atacante',
    'Volante',
    'Ponta',
    'Centroavante',
    'Zagueiro',
    'Lateral Esquerdo',
    'Lateral Direito',
    'Meia-Atacante',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _attackController.dispose();
    _defenseController.dispose();
    _staminaController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final player = PlayerModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      attack: int.parse(_attackController.text.trim()),
      defense: int.parse(_defenseController.text.trim()),
      stamina: int.parse(_staminaController.text.trim()),
      position: _selectedPosition,
    );

    widget.onSave(player);
    Navigator.of(context).pop();
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

  String? _validateAttribute(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe um valor';
    }

    final parsed = int.tryParse(value.trim());
    if (parsed == null) {
      return 'Digite um número válido';
    }

    if (parsed < 0 || parsed > 99) {
      return 'Use um valor entre 0 e 99';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar jogador'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                ),
                validator: _validateName,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _attackController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Ataque',
                ),
                validator: _validateAttribute,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _defenseController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Defesa',
                ),
                validator: _validateAttribute,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _staminaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Fôlego',
                ),
                validator: _validateAttribute,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedPosition,
                decoration: const InputDecoration(
                  labelText: 'Posição',
                ),
                items: _positions
                    .map(
                      (position) => DropdownMenuItem(
                    value: position,
                    child: Text(position),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedPosition = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}