import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/datasources/player_local_datasource.dart';
import '../../../data/models/player_model.dart';
import '../../../domain/services/ranking_service.dart';

class RankingsPage extends StatefulWidget {
  const RankingsPage({super.key});

  @override
  State<RankingsPage> createState() => _RankingsPageState();
}

class _RankingsPageState extends State<RankingsPage> {
  static const String _allSportsFilter = 'Todos';
  static const List<String> _sportOrder = [
    'Futsal',
    'Fut7',
    'Fut11',
  ];

  static const Map<String, String> _sportLabels = {
    'Futsal': 'Futsal',
    'Fut7': 'Futebol 7',
    'Fut11': 'Futebol 11',
  };

  final PlayerLocalDataSource _dataSource = PlayerLocalDataSource();
  final RankingService _rankingService = RankingService();

  Map<String, List<PlayerModel>> _rankedPlayersBySport = const {};
  String _selectedSportFilter = _allSportsFilter;

  @override
  void initState() {
    super.initState();
    _loadRankings();
  }

  void _loadRankings() {
    final players = _dataSource.getAllPlayers();

    setState(() {
      _rankedPlayersBySport = _groupAndRankPlayersBySport(players);
    });
  }

  Map<String, List<PlayerModel>> _groupAndRankPlayersBySport(
    List<PlayerModel> players,
  ) {
    final groupedPlayers = <String, List<PlayerModel>>{};

    for (final player in players) {
      groupedPlayers.putIfAbsent(
        player.sport,
        () => <PlayerModel>[],
      ).add(player);
    }

    final orderedSports = <String>[
      ..._sportOrder.where(groupedPlayers.containsKey),
      ...groupedPlayers.keys.where((sport) => !_sportOrder.contains(sport)).toList()
        ..sort(),
    ];

    final rankedPlayersBySport = <String, List<PlayerModel>>{};

    for (final sport in orderedSports) {
      final sportPlayers = groupedPlayers[sport];
      if (sportPlayers == null || sportPlayers.isEmpty) continue;

      rankedPlayersBySport[sport] = _rankingService.rankPlayers(sportPlayers);
    }

    return rankedPlayersBySport;
  }

  bool _isMobileLayout(BoxConstraints constraints) {
    return constraints.maxWidth < 600;
  }

  String _sportLabel(String sport) {
    return _sportLabels[sport] ?? sport;
  }

  List<MapEntry<String, List<PlayerModel>>> _visibleRankings() {
    final entries = _rankedPlayersBySport.entries.toList();

    if (_selectedSportFilter == _allSportsFilter) {
      return entries;
    }

    return entries.where((entry) => entry.key == _selectedSportFilter).toList();
  }

  List<DropdownMenuItem<String>> _buildFilterItems() {
    final sports = <String>[
      _allSportsFilter,
      ..._rankedPlayersBySport.keys,
    ];

    return sports
        .map(
          (sport) => DropdownMenuItem<String>(
            value: sport,
            child: Text(
              sport == _allSportsFilter ? sport : _sportLabel(sport),
            ),
          ),
        )
        .toList();
  }

  Widget _buildSportFilter() {
    return DropdownButtonFormField<String>(
      value: _selectedSportFilter,
      decoration: const InputDecoration(
        labelText: 'Esporte',
        border: OutlineInputBorder(),
      ),
      items: _buildFilterItems(),
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _selectedSportFilter = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPlayers = _rankedPlayersBySport.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go(AppRoutes.home),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar para a Home',
        ),
        title: const Text('Rankings'),
      ),
      body: hasPlayers
          ? LayoutBuilder(
              builder: (context, constraints) {
                final isMobileLayout = _isMobileLayout(constraints);
                final visibleRankings = _visibleRankings();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth:
                            constraints.maxWidth > 720 ? 720 : double.infinity,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (isMobileLayout) ...[
                            _buildSportFilter(),
                            const SizedBox(height: 16),
                          ],
                          ...visibleRankings.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _RankingSection(
                                title: _sportLabel(entry.key),
                                players: entry.value,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          : const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Nenhum jogador cadastrado ainda',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
    );
  }
}

class _RankingSection extends StatelessWidget {
  final String title;
  final List<PlayerModel> players;

  const _RankingSection({
    required this.title,
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
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...List.generate(
              players.length,
              (index) => _RankingItem(
                rank: index + 1,
                player: players[index],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankingItem extends StatelessWidget {
  final int rank;
  final PlayerModel player;

  const _RankingItem({
    required this.rank,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        child: Text('$rank'),
      ),
      title: Text(player.name),
      subtitle: Text('${player.position} - Overall ${player.overall}'),
      trailing: Text('$rank\u00BA'),
    );
  }
}
