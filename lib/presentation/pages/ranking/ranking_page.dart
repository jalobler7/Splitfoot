import 'package:flutter/material.dart';
import '../../../data/models/player_model.dart';
import '../../../domain/services/ranking_service.dart';

class RankingPage extends StatelessWidget {
  final List<PlayerModel> players;

  const RankingPage({
    super.key,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    final rankingService = RankingService();
    final rankedPlayers = rankingService.rankPlayers(players);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: rankedPlayers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final player = rankedPlayers[index];

          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text('#${index + 1}'),
              ),
              title: Text(player.name),
              subtitle: Text(
                '${player.position} • Overall ${player.overall}',
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('A: ${player.attack}'),
                  Text('D: ${player.defense}'),
                  Text('F: ${player.stamina}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}