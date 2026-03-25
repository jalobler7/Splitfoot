import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/utils/team_share_text_builder.dart';
import '../../../data/models/player_model.dart';
import '../../../domain/entities/team_result.dart';

class ResultPage extends StatefulWidget {
  final List<TeamResult> results;

  const ResultPage({
    super.key,
    required this.results,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final PageController _pageController = PageController();
  static const String _shareTitle = 'Times gerados pelo Splitfoot';
  int _currentIndex = 0;

  TeamResult get _currentResult => widget.results[_currentIndex];

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _shareCurrentResult() async {
    final shareText = buildShareText(
      teamA: _currentResult.teamA,
      teamB: _currentResult.teamB,
      title: _shareTitle,
    );
    final box = context.findRenderObject() as RenderBox?;

    await SharePlus.instance.share(
      ShareParams(
        text: shareText,
        title: _shareTitle,
        subject: _shareTitle,
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = widget.results;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Melhores Escala\u00E7\u00F5es'),
        actions: [
          IconButton(
            onPressed: _shareCurrentResult,
            icon: const Icon(Icons.share),
            tooltip: 'Compartilhar times',
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            'Op\u00E7\u00E3o ${_currentIndex + 1} de ${results.length}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.separated(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: results.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = index == _currentIndex;

                return ChoiceChip(
                  label: Text('Op\u00E7\u00E3o ${index + 1}'),
                  selected: isSelected,
                  onSelected: (_) => _goToPage(index),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: results.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final result = results[index];

                return SingleChildScrollView(
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
                              Text(
                                result.scoreLabel,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                result.score is double
                                    ? (result.score as double).toStringAsFixed(2)
                                    : result.score.toString(),
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
                                'F\u00F4lego: ${result.teamAStaminaTotal} x ${result.teamBStaminaTotal}',
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Diferen\u00E7a total: ${result.attributeDifferenceScore}',
                              ),
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
                        child: const Text('Ver Ranking desta op\u00E7\u00E3o'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
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
              '$title - M\u00E9dia: ${average.toStringAsFixed(2)}',
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
                subtitle: Text('${player.position} - Overall ${player.overall}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
