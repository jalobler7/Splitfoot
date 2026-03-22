import 'package:flutter/material.dart';
import '../../../data/datasources/player_local_datasource.dart';
import '../../../data/models/player_model.dart';

class PlayerFormDialog extends StatefulWidget {
  final Future<void> Function(PlayerModel player) onSave;
  final PlayerModel? initialPlayer;

  const PlayerFormDialog({
    super.key,
    required this.onSave,
    this.initialPlayer,
  });

  @override
  State<PlayerFormDialog> createState() => _PlayerFormDialogState();
}

class _PlayerFormDialogState extends State<PlayerFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _attackController;
  late final TextEditingController _defenseController;
  late final TextEditingController _staminaController;

  late String _selectedSport;
  late String _selectedPosition;
  bool _isSaving = false;

  final Map<String, List<String>> _positionsBySport = {
    'Futsal': [
      'Pivo',
      'Ala',
      'Fixo',
    ],
    'Fut7': [
      'Fixo',
      'Ala',
      'Meia',
      'Atacante',
    ],
    'Fut11': [
      'Lateral Esquerdo',
      'Zagueiro',
      'Lateral Direito',
      'Meia-Atacante',
      'Volante',
      'Ponta',
      'Centroavante',
    ],
  };

  bool get _isEditing => widget.initialPlayer != null;

  @override
  void initState() {
    super.initState();

    final player = widget.initialPlayer;

    _nameController = TextEditingController(text: player?.name ?? '');
    _attackController =
        TextEditingController(text: player?.attack.toString() ?? '');
    _defenseController =
        TextEditingController(text: player?.defense.toString() ?? '');
    _staminaController =
        TextEditingController(text: player?.stamina.toString() ?? '');

    _selectedSport = player?.sport ?? 'Futsal';

    final availablePositions = _positionsBySport[_selectedSport]!;
    _selectedPosition = availablePositions.contains(player?.position)
        ? player!.position
        : availablePositions.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _attackController.dispose();
    _defenseController.dispose();
    _staminaController.dispose();
    super.dispose();
  }

  void _onSportChanged(String? value) {
    if (value == null) return;

    final newPositions = _positionsBySport[value] ?? [];

    setState(() {
      _selectedSport = value;
      _selectedPosition = newPositions.first;
    });
  }

  Future<void> _save() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final existingPlayer = widget.initialPlayer;

    final player = PlayerModel(
      id: existingPlayer?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      attack: int.parse(_attackController.text.trim()),
      defense: int.parse(_defenseController.text.trim()),
      stamina: int.parse(_staminaController.text.trim()),
      position: _selectedPosition,
      sport: _selectedSport,
    );

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSave(player);
      if (!mounted) return;
      Navigator.of(context).pop();
    } on PlayerValidationException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nao foi possivel salvar o jogador. Tente novamente.'),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
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

  String? _validateAttribute(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe um valor';
    }

    final parsed = int.tryParse(value.trim());
    if (parsed == null) {
      return 'Digite um numero valido';
    }

    if (!PlayerLocalDataSource.isValidSkill(parsed)) {
      return 'Use um valor entre 0 e 99';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final currentPositions = _positionsBySport[_selectedSport]!;

    return AlertDialog(
      title: Text(_isEditing ? 'Editar jogador' : 'Adicionar jogador'),
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
                  labelText: 'Folego',
                ),
                validator: _validateAttribute,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedSport,
                decoration: const InputDecoration(
                  labelText: 'Esporte',
                ),
                items: _positionsBySport.keys
                    .map(
                      (sport) => DropdownMenuItem(
                        value: sport,
                        child: Text(sport),
                      ),
                    )
                    .toList(),
                onChanged: _isSaving ? null : _onSportChanged,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedPosition,
                decoration: const InputDecoration(
                  labelText: 'Posicao',
                ),
                items: currentPositions
                    .map(
                      (position) => DropdownMenuItem(
                        value: position,
                        child: Text(position),
                      ),
                    )
                    .toList(),
                onChanged: _isSaving
                    ? null
                    : (value) {
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
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: Text(_isEditing ? 'Salvar alteracoes' : 'Salvar'),
        ),
      ],
    );
  }
}