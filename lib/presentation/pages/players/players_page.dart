import 'package:flutter/material.dart';
import '../../../data/models/player_model.dart';
import '../../../data/datasources/player_local_datasource.dart';
import '/../widgets/players/player_form_dialog.dart';

class PlayersPage extends StatefulWidget {
  const PlayersPage({super.key});

  @override
  State<PlayersPage> createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  final PlayerLocalDataSource _dataSource = PlayerLocalDataSource();
  List<PlayerModel> _players = [];

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  void _loadPlayers() {
    final players = _dataSource.getAllPlayers();

    setState(() {
      _players = players;
    });
  }

  void _openAddPlayerDialog() {
    showDialog(
      context: context,
      builder: (_) => PlayerFormDialog(
        onSave: (player) async {
          await _dataSource.addPlayer(player);
          _loadPlayers();
        },
      ),
    );
  }

  void _removePlayer(String playerId) async {
    await _dataSource.deletePlayer(playerId);
    _loadPlayers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jogadores'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddPlayerDialog,
        child: const Icon(Icons.add),
      ),
      body: _players.isEmpty
          ? const Center(
        child: Text('Nenhum jogador cadastrado'),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _players.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final player = _players[index];

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    child: Text(player.overall.toString()),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('Posição: ${player.position}'),
                        Text('Ataque: ${player.attack}'),
                        Text('Defesa: ${player.defense}'),
                        Text('Fôlego: ${player.stamina}'),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removePlayer(player.id),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}