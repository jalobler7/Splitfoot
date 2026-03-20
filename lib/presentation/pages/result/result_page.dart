import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/player_model.dart';
import '../../../domain/entities/team_result.dart';

class ResultPage extends StatelessWidget {
  final TeamResult result;

  const ResultPage({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _TeamCard(
              title: 'Time A',
              average: result.teamAOverallAverage,
              players: result.teamA,
            ),
            const SizedBox(height: 16),
            _TeamCard(
              title: 'Time B',
              average: result.teamBOverallAverage,
              players: result.teamB,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Diferença de overall médio',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.overallDifference.toStringAsFixed(2),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Comparativo de atributos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ataque: ${result.teamAAttackTotal} x ${result.teamBAttackTotal}',
                    ),
                    Text(
                      'Defesa: ${result.teamADefenseTotal} x ${result.teamBDefenseTotal}',
                    ),
                    Text(
                      'Fôlego: ${result.teamAStaminaTotal} x ${result.teamBStaminaTotal}',
                    ),
                    const SizedBox(height: 8),
                    Text('Diferença total: ${result.attributeDifferenceScore}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final allPlayers = [
                  ...result.teamA,
                  ...result.teamB,
                ];

                context.push(
                  AppRoutes.ranking,
                  extra: allPlayers,
                );
              },
              child: const Text('Ver Ranking'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  final String title;
  final double average;
  final List<PlayerModel> players;

  const _TeamCard({
    required this.title,
    required this.average,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title - Média: ${average.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...players.map(
                  (player) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(player.name),
                subtitle: Text(
                  '${player.position} • Overall ${player.overall}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}