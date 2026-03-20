import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/enums/balance_mode.dart';
import '../../../core/enums/sport_type.dart';
import '../../../data/datasources/player_local_datasource.dart';
import '../../../data/models/player_model.dart';
import '../../../domain/services/team_balance_service.dart';

class MatchSetupPage extends StatefulWidget {
  const MatchSetupPage({super.key});

  @override
  State<MatchSetupPage> createState() => _MatchSetupPageState();
}

class _MatchSetupPageState extends State<MatchSetupPage> {
  final PlayerLocalDataSource _dataSource = PlayerLocalDataSource();
  final TeamBalanceService _teamBalanceService = TeamBalanceService();

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

  String _sportKey(SportType sport) {
    switch (sport) {
      case SportType.futsal:
        return 'Futsal';
      case SportType.fut7:
        return 'Fut7';
      case SportType.fut11:
        return 'Fut11';
    }
  }

  void _onSportChanged(SportType? value) {
    if (value == null) return;

    setState(() {
      _selectedSport = value;
      _selectedPlayers.clear();
    });
  }

  void _generateTeams() {
    final teamA = int.tryParse(_teamAController.text) ?? 0;
    final teamB = int.tryParse(_teamBController.text) ?? 0;

    final filteredPlayers = _allPlayers
        .where((player) => player.sport == _sportKey(_selectedSport))
        .toList();

    final selectedPlayersList = filteredPlayers
        .where((player) => _selectedPlayers.contains(player.id))
        .toList();

    if (teamA <= 0 || teamB <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Os dois times precisam ter ao menos 1 jogador'),
        ),
      );
      return;
    }

    if (teamA + teamB != selectedPlayersList.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quantidade de jogadores não bate com os times'),
        ),
      );
      return;
    }

    if (selectedPlayersList.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione jogadores suficientes'),
        ),
      );
      return;
    }

    try {
      switch (_balanceMode) {
        case BalanceMode.overallAverage:
          final result = _teamBalanceService.balanceByOverall(
            players: selectedPlayersList,
            teamASize: teamA,
            teamBSize: teamB,
          );

          context.push(AppRoutes.result, extra: result);
          break;

        case BalanceMode.attributes:
          final result = _teamBalanceService.balanceByAttributes(
            players: selectedPlayersList,
            teamASize: teamA,
            teamBSize: teamB,
          );

          context.push(AppRoutes.result, extra: result);
          break;

        case BalanceMode.positions:
          final result = _teamBalanceService.balanceByPosition(
            players: selectedPlayersList,
            teamASize: teamA,
            teamBSize: teamB,
            sport: _selectedSport,
          );

          context.push(AppRoutes.result, extra: result);
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao gerar times: $e'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _teamAController.dispose();
    _teamBController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visiblePlayers = _allPlayers
        .where((player) => player.sport == _sportKey(_selectedSport))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Montar Partida'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
              onChanged: _onSportChanged,
            ),
            const SizedBox(height: 12),
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _teamAController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Time A'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _teamBController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Time B'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Jogadores de ${_sportLabel(_selectedSport)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: visiblePlayers.isEmpty
                  ? const Center(
                child: Text('Nenhum jogador cadastrado para este esporte'),
              )
                  : ListView.builder(
                itemCount: visiblePlayers.length,
                itemBuilder: (context, index) {
                  final player = visiblePlayers[index];
                  final isSelected = _selectedPlayers.contains(player.id);

                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (_) => _togglePlayer(player.id),
                    title: Text(player.name),
                    subtitle: Text(
                      '${player.position} • Overall ${player.overall}',
                    ),
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