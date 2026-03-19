import 'package:flutter/material.dart';
import '../../../core/enums/sport_type.dart';
import '../../../core/enums/balance_mode.dart';
import '../../../data/models/player_model.dart';
import '../../../data/datasources/player_local_datasource.dart';

class MatchSetupPage extends StatefulWidget {
  const MatchSetupPage({super.key});

  @override
  State<MatchSetupPage> createState() => _MatchSetupPageState();
}

class _MatchSetupPageState extends State<MatchSetupPage> {
  final PlayerLocalDataSource _dataSource = PlayerLocalDataSource();

  List<PlayerModel> _allPlayers = [];
  final Set<String> _selectedPlayers = {};

  SportType _selectedSport = SportType.futsal;
  BalanceMode _balanceMode = BalanceMode.overallAverage;

  final _teamAController = TextEditingController(text: '5');
  final _teamBController = TextEditingController(text: '5');

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  void _loadPlayers() {
    final players = _dataSource.getAllPlayers();

    setState(() {
      _allPlayers = players;
    });
  }

  void _togglePlayer(String playerId) {
    setState(() {
      if (_selectedPlayers.contains(playerId)) {
        _selectedPlayers.remove(playerId);
      } else {
        _selectedPlayers.add(playerId);
      }
    });
  }

  String _sportLabel(SportType sport) {
    switch (sport) {
      case SportType.futsal:
        return 'Futsal';
      case SportType.fut7:
        return 'Fut7';
      case SportType.fut11:
        return 'Fut11';
    }
  }

  String _balanceLabel(BalanceMode mode) {
    switch (mode) {
      case BalanceMode.overallAverage:
        return 'Overall médio';
      case BalanceMode.attributes:
        return 'Atributos';
      case BalanceMode.positions:
        return 'Posições';
    }
  }

  void _generateTeams() {
    final teamA = int.tryParse(_teamAController.text) ?? 0;
    final teamB = int.tryParse(_teamBController.text) ?? 0;

    final totalSelected = _selectedPlayers.length;

    if (teamA + teamB != totalSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quantidade de jogadores não bate com os times'),
        ),
      );
      return;
    }

    if (totalSelected < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione jogadores suficientes'),
        ),
      );
      return;
    }

    // Aqui vamos implementar depois
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pronto para gerar os times 🚀'),
      ),
    );
  }

  @override
  void dispose() {
    _teamAController.dispose();
    _teamBController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Montar Partida'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Esporte
            DropdownButtonFormField<SportType>(
              value: _selectedSport,
              decoration: const InputDecoration(labelText: 'Esporte'),
              items: SportType.values
                  .map(
                    (sport) => DropdownMenuItem(
                  value: sport,
                  child: Text(_sportLabel(sport)),
                ),
              )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedSport = value);
              },
            ),

            const SizedBox(height: 12),

            // Modo de balanceamento
            DropdownButtonFormField<BalanceMode>(
              value: _balanceMode,
              decoration: const InputDecoration(labelText: 'Modo de divisão'),
              items: BalanceMode.values
                  .map(
                    (mode) => DropdownMenuItem(
                  value: mode,
                  child: Text(_balanceLabel(mode)),
                ),
              )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _balanceMode = value);
              },
            ),

            const SizedBox(height: 12),

            // Times
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _teamAController,
                    keyboardType: TextInputType.number,
                    decoration:
                    const InputDecoration(labelText: 'Time A'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _teamBController,
                    keyboardType: TextInputType.number,
                    decoration:
                    const InputDecoration(labelText: 'Time B'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Jogadores',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: _allPlayers.isEmpty
                  ? const Center(child: Text('Nenhum jogador cadastrado'))
                  : ListView.builder(
                itemCount: _allPlayers.length,
                itemBuilder: (context, index) {
                  final player = _allPlayers[index];
                  final isSelected =
                  _selectedPlayers.contains(player.id);

                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (_) => _togglePlayer(player.id),
                    title: Text(player.name),
                    subtitle: Text(
                        '${player.position} • Overall ${player.overall}'),
                  );
                },
              ),
            ),

            ElevatedButton(
              onPressed: _generateTeams,
              child: const Text('Gerar Times'),
            ),
          ],
        ),
      ),
    );
  }
}