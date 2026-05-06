import 'package:flutter/material.dart';
import '../../../data/datasources/player_local_datasource.dart';
import '../../../data/models/player_model.dart';
import '../../../data/models/team_group_model.dart';

class PlayerFormDialog extends StatefulWidget {
  final Future<void> Function(PlayerModel player) onSave;
  final PlayerModel? initialPlayer;
  final List<TeamGroupModel> availableGroups;
  final Future<TeamGroupModel?> Function() onCreateGroupRequested;

  const PlayerFormDialog({
    super.key,
    required this.onSave,
    required this.availableGroups,
    required this.onCreateGroupRequested,
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
  late List<TeamGroupModel> _groups;
  String? _selectedGroupId;
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
    _groups = List<TeamGroupModel>.from(widget.availableGroups);

    final availablePositions = _positionsBySport[_selectedSport]!;
    _selectedPosition = availablePositions.contains(player?.position)
        ? player!.position
        : availablePositions.first;
    _selectedGroupId = player?.teamGroupId;

    if (_selectedGroupId == null && _groups.isNotEmpty) {
      _selectedGroupId = _groups.first.id;
    }
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
      teamGroupId: _selectedGroupId ?? '',
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

  Future<void> _createGroupFromDialog() async {
    final createdGroup = await widget.onCreateGroupRequested();
    if (!mounted || createdGroup == null) return;

    setState(() {
      final alreadyExists = _groups.any((group) => group.id == createdGroup.id);
      if (!alreadyExists) {
        _groups.add(createdGroup);
      }
      _selectedGroupId = createdGroup.id;
    });
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
              if (_groups.isEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Crie um grupo antes de cadastrar atletas.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton(
                          onPressed: _isSaving ? null : _createGroupFromDialog,
                          child: const Text('Criar grupo'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ] else ...[
                DropdownButtonFormField<String>(
                  value: _selectedGroupId,
                  decoration: const InputDecoration(
                    labelText: 'Selecionar grupo',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Selecione um grupo';
                    }
                    return null;
                  },
                  items: _groups
                      .map(
                        (group) => DropdownMenuItem(
                          value: group.id,
                          child: Text(group.name),
                        ),
                      )
                      .toList(),
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          setState(() {
                            _selectedGroupId = value;
                          });
                        },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _isSaving ? null : _createGroupFromDialog,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Criar grupo'),
                  ),
                ),
                const SizedBox(height: 4),
              ],
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
          onPressed: _isSaving || _groups.isEmpty ? null : _save,
          child: Text(_isEditing ? 'Salvar alteracoes' : 'Salvar'),
        ),
      ],
    );
  }
}
