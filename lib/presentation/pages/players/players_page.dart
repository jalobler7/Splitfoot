import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/datasources/player_local_datasource.dart';
import '../../../data/models/player_model.dart';
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

  void _openEditPlayerDialog(PlayerModel player) {
    showDialog(
      context: context,
      builder: (_) => PlayerFormDialog(
        initialPlayer: player,
        onSave: (updatedPlayer) async {
          await _dataSource.updatePlayer(updatedPlayer);
          _loadPlayers();
        },
      ),
    );
  }

  Future<void> _removePlayer(String playerId) async {
    await _dataSource.deletePlayer(playerId);
    if (!mounted) return;
    _loadPlayers();
  }

  Future<void> _confirmDeletePlayer(PlayerModel player) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: const Text('Tem certeza que deseja excluir este jogador?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await _removePlayer(player.id);
              if (!dialogContext.mounted) return;
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jogadores'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
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
                        Text('Esporte: ${player.sport}'),
                        Text('Posição: ${player.position}'),
                        Text('Ataque: ${player.attack}'),
                        Text('Defesa: ${player.defense}'),
                        Text('Fôlego: ${player.stamina}'),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () => _openEditPlayerDialog(player),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        onPressed: () => _confirmDeletePlayer(player),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
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
