import 'dart:math' as math;

import 'package:divide_time/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/datasources/player_local_datasource.dart';
import '../../../data/datasources/team_group_local_datasource.dart';
import '../../../data/models/player_model.dart';
import '../../../data/models/team_group_model.dart';
import '../../../domain/services/ranking_service.dart';
import '../../../widgets/player_visuals.dart';

class RankingsPage extends StatefulWidget {
  const RankingsPage({super.key});

  @override
  State<RankingsPage> createState() => _RankingsPageState();
}

class _RankingsPageState extends State<RankingsPage> {
  static const String _allSportsFilter = 'Todos';
  static const List<String> _sportOrder = ['Futsal', 'Fut7', 'Fut11'];
  static const Map<String, String> _sportLabels = {
    'Futsal': 'Futsal',
    'Fut7': 'Futebol 7',
    'Fut11': 'Futebol 11',
  };
  static const List<_RankingCategory> _categories = [
    _RankingCategory('overall', 'Geral', Icons.workspace_premium_rounded),
    _RankingCategory('attack', 'Ataque', Icons.bolt_rounded),
    _RankingCategory('defense', 'Defesa', Icons.shield_rounded),
    _RankingCategory('stamina', 'Folego', Icons.local_fire_department_rounded),
    _RankingCategory('goalkeeper', 'Goleiros', Icons.sports_handball_rounded),
  ];

  final PlayerLocalDataSource _dataSource = PlayerLocalDataSource();
  final TeamGroupLocalDataSource _groupDataSource = TeamGroupLocalDataSource();
  final RankingService _rankingService = RankingService();

  Map<String, List<PlayerModel>> _playersBySport = const {};
  List<TeamGroupModel> _groups = [];
  String? _selectedGroupId;
  String _selectedSportFilter = _allSportsFilter;
  String _selectedCategory = _categories.first.id;

  @override
  void initState() {
    super.initState();
    _loadRankings();
  }

  void _loadRankings() {
    final players = _dataSource.getAllPlayers();
    final groups = _groupDataSource.getAllGroups();
    final selectedGroupId = _resolveSelectedGroupId(groups);
    final groupedPlayers = <String, List<PlayerModel>>{};

    for (final player in players.where((item) => item.teamGroupId == selectedGroupId)) {
      groupedPlayers.putIfAbsent(player.sport, () => <PlayerModel>[]).add(player);
    }

    final orderedSports = <String>[
      ..._sportOrder.where(groupedPlayers.containsKey),
      ...groupedPlayers.keys.where((sport) => !_sportOrder.contains(sport)).toList()
        ..sort(),
    ];

    setState(() {
      _groups = groups;
      _selectedGroupId = selectedGroupId;
      if (_selectedSportFilter != _allSportsFilter &&
          !orderedSports.contains(_selectedSportFilter)) {
        _selectedSportFilter = _allSportsFilter;
      }
      _playersBySport = {
        for (final sport in orderedSports) sport: List<PlayerModel>.from(groupedPlayers[sport]!),
      };
    });
  }

  String? _resolveSelectedGroupId(List<TeamGroupModel> groups) {
    if (groups.isEmpty) return null;
    if (_selectedGroupId != null && groups.any((group) => group.id == _selectedGroupId)) {
      return _selectedGroupId;
    }
    return groups.first.id;
  }

  String _selectedGroupName() {
    for (final group in _groups) {
      if (group.id == _selectedGroupId) {
        return group.name;
      }
    }
    return 'Selecionar grupo';
  }

  String _sportLabel(String sport) => _sportLabels[sport] ?? sport;

  List<MapEntry<String, List<PlayerModel>>> _visibleRankings() {
    final sports = _selectedSportFilter == _allSportsFilter
        ? _playersBySport.entries.toList()
        : _playersBySport.entries.where((entry) => entry.key == _selectedSportFilter).toList();

    return sports
        .map((entry) => MapEntry(entry.key, _sortPlayersByCategory(entry.value, _selectedCategory)))
        .where((entry) => entry.value.isNotEmpty)
        .toList();
  }

  List<PlayerModel> _sortPlayersByCategory(List<PlayerModel> players, String categoryId) {
    return switch (categoryId) {
      'overall' => _rankingService.rankPlayers(players),
      'attack' => _sortByMetric(players, (player) => player.attack, fallback: (player) => player.overall),
      'defense' => _sortByMetric(players, (player) => player.defense, fallback: (player) => player.overall),
      'stamina' => _sortByMetric(players, (player) => player.stamina, fallback: (player) => player.overall),
      'goalkeeper' => _sortGoalkeepers(players),
      _ => _rankingService.rankPlayers(players),
    };
  }

  List<PlayerModel> _sortByMetric(
    List<PlayerModel> players,
    int Function(PlayerModel player) metric, {
    required int Function(PlayerModel player) fallback,
  }) {
    final sorted = List<PlayerModel>.from(players);
    sorted.sort((a, b) {
      final metricCompare = metric(b).compareTo(metric(a));
      if (metricCompare != 0) return metricCompare;

      final fallbackCompare = fallback(b).compareTo(fallback(a));
      if (fallbackCompare != 0) return fallbackCompare;

      return a.name.compareTo(b.name);
    });
    return sorted;
  }

  List<PlayerModel> _sortGoalkeepers(List<PlayerModel> players) {
    final goalkeepers = players.where(_isGoalkeeper).toList();
    goalkeepers.sort((a, b) {
      final defenseCompare = b.defense.compareTo(a.defense);
      if (defenseCompare != 0) return defenseCompare;

      final overallCompare = b.overall.compareTo(a.overall);
      if (overallCompare != 0) return overallCompare;

      final staminaCompare = b.stamina.compareTo(a.stamina);
      if (staminaCompare != 0) return staminaCompare;

      return a.name.compareTo(b.name);
    });
    return goalkeepers;
  }

  bool _isGoalkeeper(PlayerModel player) {
    final position = player.position.toLowerCase();
    return position.contains('gol');
  }

  List<String> _availableSports() => [_allSportsFilter, ..._playersBySport.keys];

  List<PlayerModel> _statsPool() {
    final visibleSports = _selectedSportFilter == _allSportsFilter
        ? _playersBySport.values
        : [
            if (_playersBySport.containsKey(_selectedSportFilter)) _playersBySport[_selectedSportFilter]!,
          ];
    return visibleSports.expand((players) => players).toList();
  }

  _HighlightStats? _buildHighlightStats() {
    final players = _statsPool();
    if (players.isEmpty) return null;

    return _HighlightStats(
      attackLeader: _sortByMetric(players, (player) => player.attack, fallback: (player) => player.overall).first,
      defenseLeader: _sortByMetric(players, (player) => player.defense, fallback: (player) => player.overall).first,
      staminaLeader: _sortByMetric(players, (player) => player.stamina, fallback: (player) => player.overall).first,
      overallLeader: _rankingService.rankPlayers(players).first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleRankings = _visibleRankings();
    final highlightStats = _buildHighlightStats();
    final hasGroups = _groups.isNotEmpty;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 86,
        leadingWidth: 76,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
          child: _IconSurfaceButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => context.go(AppRoutes.home),
            tooltip: 'Voltar para a Home',
          ),
        ),
        title: const Padding(
          padding: EdgeInsets.only(top: 10, right: 20),
          child: _AppBarTitle(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF09120D),
              AppColors.background,
              Color(0xFF0D1117),
            ],
          ),
        ),
        child: SafeArea(
          child: hasGroups
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    final contentMaxWidth = constraints.maxWidth > 860 ? 860.0 : double.infinity;

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 94, 16, 24),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: contentMaxWidth),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _RankingsHeroCard(
                                groupLabel: _selectedGroupName(),
                                sportLabel: _selectedSportFilter == _allSportsFilter
                                    ? 'Todos os formatos'
                                    : _sportLabel(_selectedSportFilter),
                                categoryLabel: _categories.firstWhere((item) => item.id == _selectedCategory).label,
                                totalPlayers: visibleRankings.fold<int>(0, (sum, entry) => sum + entry.value.length),
                              ),
                              const SizedBox(height: 20),
                              _FilterSection(
                                title: 'Grupo',
                                items: _groups
                                    .map(
                                      (group) => _FilterChipData(
                                        id: group.id,
                                        label: group.name,
                                        icon: Icons.folder_copy_rounded,
                                      ),
                                    )
                                    .toList(),
                                selectedId: _selectedGroupId ?? '',
                                onSelected: (value) {
                                  setState(() {
                                    _selectedGroupId = value;
                                    _selectedSportFilter = _allSportsFilter;
                                  });
                                  _loadRankings();
                                },
                              ),
                              const SizedBox(height: 16),
                              _FilterSection(
                                title: 'Esporte',
                                items: _availableSports()
                                    .map(
                                      (sport) => _FilterChipData(
                                        id: sport,
                                        label: sport == _allSportsFilter ? 'Todos' : _sportLabel(sport),
                                      ),
                                    )
                                    .toList(),
                                selectedId: _selectedSportFilter,
                                onSelected: (value) => setState(() => _selectedSportFilter = value),
                              ),
                              const SizedBox(height: 16),
                              _FilterSection(
                                title: 'Categoria',
                                items: _categories
                                    .map(
                                      (category) => _FilterChipData(
                                        id: category.id,
                                        label: category.label,
                                        icon: category.icon,
                                      ),
                                    )
                                    .toList(),
                                selectedId: _selectedCategory,
                                onSelected: (value) => setState(() => _selectedCategory = value),
                              ),
                              if (highlightStats != null) ...[
                                const SizedBox(height: 24),
                                _HighlightsSection(stats: highlightStats),
                              ],
                              const SizedBox(height: 24),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 320),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                child: visibleRankings.isEmpty
                                    ? const _EmptyCategoryState(key: ValueKey('empty-category'))
                                    : Column(
                                        key: ValueKey('${_selectedGroupId}_${_selectedSportFilter}_$_selectedCategory'),
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          for (var index = 0; index < visibleRankings.length; index++) ...[
                                            _RankingSection(
                                              title: _sportLabel(visibleRankings[index].key),
                                              players: visibleRankings[index].value,
                                              categoryId: _selectedCategory,
                                            ),
                                            if (index != visibleRankings.length - 1) const SizedBox(height: 24),
                                          ],
                                        ],
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
                    child: _EmptyPlayersState(),
                  ),
                ),
        ),
      ),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text(
          'Splitfoot',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Rankings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _RankingsHeroCard extends StatelessWidget {
  const _RankingsHeroCard({
    required this.groupLabel,
    required this.sportLabel,
    required this.categoryLabel,
    required this.totalPlayers,
  });

  final String groupLabel;
  final String sportLabel;
  final String categoryLabel;
  final int totalPlayers;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF17241C),
            Color(0xFF0F1813),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                ),
                child: const Text(
                  'COMPETITIVO',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.05,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withValues(alpha: 0.04),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Color(0xFFF2C94C),
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Desempenho, disputa e leitura rápida para decidir quem chega no topo.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Compare atletas por esporte e categoria com uma hierarquia visual mais clara e foco total nos melhores da partida.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _OverviewBadge(icon: Icons.folder_copy_rounded, label: groupLabel),
              _OverviewBadge(icon: Icons.filter_alt_rounded, label: sportLabel),
              _OverviewBadge(icon: Icons.tune_rounded, label: categoryLabel),
              _OverviewBadge(icon: Icons.groups_rounded, label: '$totalPlayers jogadores'),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewBadge extends StatelessWidget {
  const _OverviewBadge({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
           ),
          ),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.title,
    required this.items,
    required this.selectedId,
    required this.onSelected,
  });

  final String title;
  final List<_FilterChipData> items;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = item.id == selectedId;

              return _PressableScale(
                borderRadius: BorderRadius.circular(18),
                onTap: () => onSelected(item.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: isSelected
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF2ED165),
                              Color(0xFF148C45),
                            ],
                          )
                        : null,
                    color: isSelected ? null : const Color(0xFF151A1C),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.18)
                          : Colors.white.withValues(alpha: 0.08),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.26),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.icon != null) ...[
                        Icon(item.icon, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        item.label,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: isSelected ? 1 : 0.92),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemCount: items.length,
          ),
        ),
      ],
    );
  }
}

class _HighlightsSection extends StatelessWidget {
  const _HighlightsSection({
    required this.stats,
  });

  final _HighlightStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Destaques do momento',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth < 720
                ? constraints.maxWidth
                : (constraints.maxWidth - 12) / 2;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: _HighlightCard(
                    title: 'Melhor ataque',
                    player: stats.attackLeader,
                    value: '${stats.attackLeader.attack} ATA',
                    icon: Icons.bolt_rounded,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _HighlightCard(
                    title: 'Melhor defesa',
                    player: stats.defenseLeader,
                    value: '${stats.defenseLeader.defense} DEF',
                    icon: Icons.shield_rounded,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _HighlightCard(
                    title: 'Melhor preparo fisico',
                    player: stats.staminaLeader,
                    value: '${stats.staminaLeader.stamina} FOL',
                    icon: Icons.local_fire_department_rounded,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _HighlightCard(
                    title: 'Jogador mais completo',
                    player: stats.overallLeader,
                    value: '${stats.overallLeader.overall} OVR',
                    icon: Icons.auto_awesome_rounded,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.title,
    required this.player,
    required this.value,
    required this.icon,
  });

  final String title;
  final PlayerModel player;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF13181A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  player.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  player.position,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.68),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          _ScoreBadge(label: value),
        ],
      ),
    );
  }
}

class _RankingSection extends StatelessWidget {
  const _RankingSection({
    required this.title,
    required this.players,
    required this.categoryId,
  });

  final String title;
  final List<PlayerModel> players;
  final String categoryId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111719),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${players.length} atletas ranqueados',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _SectionBadge(categoryId: categoryId),
            ],
          ),
          const SizedBox(height: 22),
          ...List.generate(
            players.length,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: index == players.length - 1 ? 0 : 12),
              child: _RankingListItem(
                rank: index + 1,
                player: players[index],
                categoryId: categoryId,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingListItem extends StatelessWidget {
  const _RankingListItem({
    required this.rank,
    required this.player,
    required this.categoryId,
  });

  final int rank;
  final PlayerModel player;
  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final placementColor = _placementColor(rank);
    final placementIcon = _placementIcon(rank);
    final isTopThree = rank <= 3;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isTopThree
                ? placementColor.withValues(alpha: 0.16)
                : rank <= 5
                    ? AppColors.primary.withValues(alpha: 0.10)
                    : const Color(0xFF161C1F),
            const Color(0xFF111618),
          ],
        ),
        border: Border.all(
          color: isTopThree
              ? placementColor.withValues(alpha: 0.28)
              : Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 360;
            final badgeSize = isNarrow ? 54.0 : 62.0;
            final gap = isNarrow ? 10.0 : 12.0;
            final nameSize = isNarrow ? 15.5 : 17.0;
            final metaWidth = isNarrow ? 104.0 : 116.0;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 0,
                  child: _RankingOverallBadge(value: player.overall, size: badgeSize),
                ),
                SizedBox(width: gap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: isNarrow ? 6 : 8,
                        runSpacing: isNarrow ? 6 : 8,
                        children: [
                          _RankingPlacementPill(
                            rank: rank,
                            accentColor: isTopThree ? placementColor : null,
                            icon: placementIcon,
                            compact: isNarrow,
                          ),
                          _ScoreBadge(
                            label: _scoreLabel(player, categoryId),
                            highlight: rank == 1,
                            compact: isNarrow,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        player.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: nameSize,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: isNarrow ? 6 : 8,
                        runSpacing: isNarrow ? 6 : 8,
                        children: [
                          _RankingMetaPill(
                            icon: Icons.sports_soccer_rounded,
                            label: player.sport,
                            compact: isNarrow,
                            maxWidth: metaWidth,
                          ),
                          _RankingMetaPill(
                            icon: Icons.shield_outlined,
                            label: player.position,
                            isPosition: true,
                            compact: isNarrow,
                            maxWidth: metaWidth,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Color _placementColor(int rank) {
  switch (rank) {
    case 1:
      return const Color(0xFFF2C94C);
    case 2:
      return const Color(0xFFC0C7D1);
    case 3:
      return const Color(0xFFD28B61);
    default:
      return Colors.white;
  }
}

IconData? _placementIcon(int rank) {
  switch (rank) {
    case 1:
      return Icons.emoji_events_rounded;
    case 2:
      return Icons.workspace_premium_rounded;
    case 3:
      return Icons.military_tech_rounded;
    default:
      return null;
  }
}

class _RankingOverallBadge extends StatelessWidget {
  const _RankingOverallBadge({
    required this.value,
    this.size = 68,
  });

  final int value;
  final double size;

  @override
  Widget build(BuildContext context) {
    final innerSize = size - 12;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF35D76C),
            Color(0xFF178C46),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.24),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: innerSize,
          height: innerSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'OVR',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: size * 0.15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '$value',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.29,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RankingPlacementPill extends StatelessWidget {
  const _RankingPlacementPill({
    required this.rank,
    this.accentColor,
    this.icon,
    this.compact = false,
  });

  final int rank;
  final Color? accentColor;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? Colors.white;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: compact ? 11 : 13, color: color),
            SizedBox(width: compact ? 4 : 5),
          ],
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${rank}\u00BA lugar',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: compact ? 10.5 : 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingMetaPill extends StatelessWidget {
  const _RankingMetaPill({
    required this.icon,
    required this.label,
    this.isPosition = false,
    this.compact = false,
    this.maxWidth = 116,
  });

  final IconData icon;
  final String label;
  final bool isPosition;
  final bool compact;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final style = isPosition ? positionVisualStyle(label) : null;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: isPosition ? style!.background : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isPosition ? style!.border : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: compact ? 12 : 14,
            color: isPosition ? style!.foreground : AppColors.primary,
          ),
          SizedBox(width: compact ? 5 : 6),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isPosition ? style!.foreground : Colors.white.withValues(alpha: 0.78),
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({
    required this.label,
    this.highlight = false,
    this.compact = false,
  });

  final String label;
  final bool highlight;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 12,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: highlight
              ? [
                  const Color(0xFF34D46A),
                  const Color(0xFF169A49),
                ]
              : [
                  AppColors.primary.withValues(alpha: 0.18),
                  AppColors.primary.withValues(alpha: 0.10),
                ],
        ),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: highlight ? 0.18 : 0.26),
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          maxLines: 1,
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 10.5 : 12,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }
}

class _SectionBadge extends StatelessWidget {
  const _SectionBadge({
    required this.categoryId,
  });

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final category = _RankingsPageState._categories.firstWhere(
      (item) => item.id == categoryId,
      orElse: () => _RankingsPageState._categories.first,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Text(
            category.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPlayersState extends StatelessWidget {
  const _EmptyPlayersState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF13181A),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.groups_rounded,
            color: AppColors.primary,
            size: 42,
          ),
          SizedBox(height: 14),
          Text(
            'Nenhum jogador cadastrado ainda',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Adicione atletas para liberar os rankings e comparar desempenho por esporte.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCategoryState extends StatelessWidget {
  const _EmptyCategoryState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF13181A),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            color: AppColors.primary,
            size: 40,
          ),
          SizedBox(height: 14),
          Text(
            'Nenhum atleta encontrado nesta categoria',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Troque o esporte ou selecione outra categoria para visualizar o ranking.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconSurfaceButton extends StatelessWidget {
  const _IconSurfaceButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: _PressableScale(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Center(
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

class _PressableScale extends StatefulWidget {
  const _PressableScale({
    required this.child,
    required this.onTap,
    required this.borderRadius,
  });

  final Widget child;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: widget.borderRadius,
          splashColor: Colors.white.withValues(alpha: 0.06),
          highlightColor: Colors.white.withValues(alpha: 0.02),
          onHighlightChanged: (value) {
            if (_isPressed == value) return;
            setState(() {
              _isPressed = value;
            });
          },
          onTap: widget.onTap,
          child: widget.child,
        ),
      ),
    );
  }
}

class _RankingCategory {
  const _RankingCategory(this.id, this.label, this.icon);

  final String id;
  final String label;
  final IconData icon;
}

class _FilterChipData {
  const _FilterChipData({
    required this.id,
    required this.label,
    this.icon,
  });

  final String id;
  final String label;
  final IconData? icon;
}

class _HighlightStats {
  const _HighlightStats({
    required this.attackLeader,
    required this.defenseLeader,
    required this.staminaLeader,
    required this.overallLeader,
  });

  final PlayerModel attackLeader;
  final PlayerModel defenseLeader;
  final PlayerModel staminaLeader;
  final PlayerModel overallLeader;
}

String _scoreLabel(PlayerModel player, String categoryId) {
  return switch (categoryId) {
    'attack' => '${player.attack} ATA',
    'defense' => '${player.defense} DEF',
    'stamina' => '${player.stamina} FOL',
    'goalkeeper' => '${math.max(player.defense, player.overall)} GK',
    _ => '${player.overall} OVR',
  };
}
