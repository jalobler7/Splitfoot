import 'package:divide_time/app/routes/app_routes.dart';
import 'package:divide_time/app/theme/app_colors.dart';
import 'package:divide_time/data/datasources/player_local_datasource.dart';
import 'package:divide_time/data/models/player_model.dart';
import 'package:divide_time/widgets/player_visuals.dart';
import 'package:divide_time/widgets/players/player_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlayersPage extends StatefulWidget {
  const PlayersPage({super.key});

  @override
  State<PlayersPage> createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  final PlayerLocalDataSource _dataSource = PlayerLocalDataSource();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<PlayerModel> _allPlayers = [];
  List<PlayerModel> _filteredPlayers = [];

  String _searchQuery = '';
  final Set<String> _selectedPositions = {};
  String? _selectedSport;
  int _currentPage = 0;
  bool _isHeaderCompact = false;
  static const int _pageSize = 5;

  static const List<String> _sportOptions = [
    'Futsal',
    'Fut7',
    'Fut11',
  ];

  List<String> get _availablePositions {
    final playersBySport = _selectedSport == null
        ? _allPlayers
        : _allPlayers.where((player) => player.sport == _selectedSport).toList();

    final positions = playersBySport.map((player) => player.position).toSet();
    final orderedPositions = positions.toList()..sort();
    return orderedPositions;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    _loadPlayers();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldCompact = _scrollController.hasClients && _scrollController.offset > 24;
    if (shouldCompact == _isHeaderCompact) return;

    setState(() {
      _isHeaderCompact = shouldCompact;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    if (query == _searchQuery) return;

    _updateFilteredPlayers(() {
      _searchQuery = query;
    });
  }

  void _loadPlayers() {
    final players = _dataSource.getAllPlayers();

    _updateFilteredPlayers(() {
      _allPlayers = players;
      _syncSelectedPositionsWithAvailable();
    });
  }

  List<PlayerModel> _applyFilters() {
    final filtered = _allPlayers.where((player) {
      final matchesName =
          _searchQuery.isEmpty || player.name.toLowerCase().contains(_searchQuery);
      final matchesSport =
          _selectedSport == null || player.sport == _selectedSport;
      final matchesPosition = _selectedPositions.isEmpty ||
          _selectedPositions.contains(player.position);

      return matchesName && matchesSport && matchesPosition;
    }).toList();

    filtered.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    return filtered;
  }

  void _updateFilteredPlayers([VoidCallback? updates]) {
    setState(() {
      updates?.call();
      _filteredPlayers = _applyFilters();
      _currentPage = 0;
    });
  }

  void _syncSelectedPositionsWithAvailable() {
    final available = _availablePositions.toSet();
    _selectedPositions.removeWhere((position) => !available.contains(position));
  }

  void _onSportChanged(String? sport) {
    if (_selectedSport == sport) return;

    _updateFilteredPlayers(() {
      _selectedSport = sport;
      _syncSelectedPositionsWithAvailable();
    });
  }

  void _togglePositionFilter(String position) {
    _updateFilteredPlayers(() {
      if (_selectedPositions.contains(position)) {
        _selectedPositions.remove(position);
      } else {
        _selectedPositions.add(position);
      }
    });
  }

  int get _totalPages {
    if (_filteredPlayers.isEmpty) return 1;
    return (_filteredPlayers.length / _pageSize).ceil();
  }

  List<PlayerModel> get _paginatedPlayers {
    if (_filteredPlayers.isEmpty) return const [];
    final start = _currentPage * _pageSize;
    final end = (start + _pageSize).clamp(0, _filteredPlayers.length);
    return _filteredPlayers.sublist(start, end);
  }

  void _goToPreviousPage() {
    if (_currentPage == 0) return;
    setState(() {
      _currentPage -= 1;
    });
    _scrollListToTop();
  }

  void _goToNextPage() {
    if (_currentPage >= _totalPages - 1) return;
    setState(() {
      _currentPage += 1;
    });
    _scrollListToTop();
  }

  void _scrollListToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
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
        backgroundColor: const Color(0xFF14191B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Excluir jogador',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Tem certeza que deseja excluir ${player.name}?',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.74)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
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
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      floatingActionButton: _PremiumFab(onTap: _openAddPlayerDialog),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0B1510),
              AppColors.background,
              Color(0xFF0E1217),
            ],
          ),
        ),
        child: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                _PlayersHeader(
                  theme: theme,
                  filteredCount: _filteredPlayers.length,
                  isCompact: _isHeaderCompact,
                  searchField: _SearchField(
                    controller: _searchController,
                    hasQuery: _searchQuery.isNotEmpty,
                    onClear: () => _searchController.clear(),
                    compact: _isHeaderCompact,
                  ),
                  sportDropdown: _SportDropdown(
                    value: _selectedSport,
                    items: _sportOptions,
                    onChanged: _onSportChanged,
                    compact: _isHeaderCompact,
                  ),
                  positionsContent: Align(
                    alignment: Alignment.centerLeft,
                    child: _availablePositions.isEmpty
                        ? const _InlineNotice(
                            text: 'Nenhuma posi\u00E7\u00E3o dispon\u00EDvel para o filtro.',
                          )
                        : Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _availablePositions.map((position) {
                              final isSelected =
                                  _selectedPositions.contains(position);
                              return _PositionChip(
                                label: position,
                                selected: isSelected,
                                onTap: () => _togglePositionFilter(position),
                              );
                            }).toList(),
                          ),
                  ),
                  positionSubtitle: _selectedPositions.isEmpty
                      ? 'Todas as posi\u00E7\u00F5es'
                      : '${_selectedPositions.length} filtro(s) ativo(s)',
                  onBack: () => context.go(AppRoutes.home),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  height: _isHeaderCompact ? 12 : 18,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: _buildPlayerContent(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerContent() {
    if (_allPlayers.isEmpty) {
      return const _EmptyState(
        key: ValueKey('empty-all'),
        icon: Icons.groups_outlined,
        title: 'Nenhum jogador cadastrado',
        subtitle: 'Adicione jogadores para come\u00E7ar a montar partidas equilibradas.',
      );
    }

    if (_filteredPlayers.isEmpty) {
      return const _EmptyState(
        key: ValueKey('empty-filtered'),
        icon: Icons.search_off_rounded,
        title: 'Nenhum jogador encontrado',
        subtitle: 'Ajuste a busca ou os filtros para encontrar resultados.',
      );
    }

    return ListView.separated(
      key: const ValueKey('player-list'),
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 108),
      itemCount: _paginatedPlayers.length + 1,
      separatorBuilder: (_, index) =>
          index == _paginatedPlayers.length - 1 ? const SizedBox(height: 18) : const SizedBox(height: 14),
      itemBuilder: (context, index) {
        if (index == _paginatedPlayers.length) {
          return _PaginationBar(
            currentPage: _currentPage + 1,
            totalPages: _totalPages,
            canGoBack: _currentPage > 0,
            canGoForward: _currentPage < _totalPages - 1,
            onPrevious: _goToPreviousPage,
            onNext: _goToNextPage,
          );
        }

        final player = _paginatedPlayers[index];
        return _PlayerCard(
          player: player,
          onEdit: () => _openEditPlayerDialog(player),
          onDelete: () => _confirmDeletePlayer(player),
        );
      },
    );
  }
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 1),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayersHeader extends StatelessWidget {
  const _PlayersHeader({
    required this.theme,
    required this.filteredCount,
    required this.isCompact,
    required this.searchField,
    required this.sportDropdown,
    required this.positionsContent,
    required this.positionSubtitle,
    required this.onBack,
  });

  final ThemeData theme;
  final int filteredCount;
  final bool isCompact;
  final Widget searchField;
  final Widget sportDropdown;
  final Widget positionsContent;
  final String positionSubtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.fromLTRB(16, isCompact ? 14 : 18, 16, isCompact ? 14 : 18),
      decoration: BoxDecoration(
        color: const Color(0xFF12191A).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
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
              _TopIconButton(
                icon: Icons.arrow_back_rounded,
                onTap: onBack,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jogadores',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontSize: isCompact ? 24 : 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: isCompact
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                '$filteredCount visiveis',
                                key: ValueKey(filteredCount),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.54),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              if (isCompact) _CompactCounterBadge(count: filteredCount),
            ],
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            height: isCompact ? 12 : 18,
          ),
          searchField,
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            height: isCompact ? 10 : 14,
          ),
          sportDropdown,
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            height: isCompact ? 12 : 16,
          ),
          _SectionLabel(
            title: 'Posicoes',
            subtitle: positionSubtitle,
            compact: isCompact,
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            height: isCompact ? 8 : 10,
          ),
          positionsContent,
        ],
      ),
    );
  }
}

class _CompactCounterBadge extends StatelessWidget {
  const _CompactCounterBadge({
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.20)),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hasQuery,
    required this.onClear,
    required this.compact,
  });

  final TextEditingController controller;
  final bool hasQuery;
  final VoidCallback onClear;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: 'Buscar jogador por nome',
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.40),
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Icon(
            Icons.search_rounded,
            color: Colors.white.withValues(alpha: 0.56),
            size: 22,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 46, minHeight: 46),
        suffixIcon: hasQuery
            ? IconButton(
                onPressed: onClear,
                icon: Icon(
                  Icons.close_rounded,
                  color: Colors.white.withValues(alpha: 0.62),
                  size: 20,
                ),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFF141A1D),
        contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: compact ? 14 : 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.75),
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class _SportDropdown extends StatelessWidget {
  const _SportDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.compact,
  });

  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      value: value,
      dropdownColor: const Color(0xFF161C1F),
      borderRadius: BorderRadius.circular(22),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Colors.white.withValues(alpha: 0.72),
      ),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: 'Esporte',
        labelStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.58),
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          Icons.sports_soccer_rounded,
          color: AppColors.primary.withValues(alpha: 0.88),
          size: 22,
        ),
        filled: true,
        fillColor: const Color(0xFF141A1D),
        contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: compact ? 14 : 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.75),
            width: 1.4,
          ),
        ),
      ),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('Todos os esportes'),
        ),
        ...items.map(
          (sport) => DropdownMenuItem<String?>(
            value: sport,
            child: Text(sport),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.title,
    required this.subtitle,
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 14 : 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              if (!compact) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.52),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.64),
          fontSize: 13,
        ),
      ),
    );
  }
}

class _PositionChip extends StatelessWidget {
  const _PositionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = positionVisualStyle(label);
    return _PressableScale(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? style.background
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? style.border
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: style.foreground,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? style.foreground
                    : Colors.white.withValues(alpha: 0.76),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    required this.player,
    required this.onEdit,
    required this.onDelete,
  });

  final PlayerModel player;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF161C1F),
            Color(0xFF111618),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OverallBadge(value: player.overall),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _MetaPill(
                            icon: Icons.sports_soccer_rounded,
                            label: player.sport,
                          ),
                          _MetaPill(
                            icon: Icons.shield_outlined,
                            label: player.position,
                            isPosition: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    _CardActionButton(
                      icon: Icons.edit_outlined,
                      onTap: onEdit,
                    ),
                    const SizedBox(height: 8),
                    _CardActionButton(
                      icon: Icons.delete_outline_rounded,
                      isDanger: true,
                      onTap: onDelete,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _AttributeTile(
                    label: 'Ataque',
                    value: player.attack,
                    icon: Icons.north_east_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _AttributeTile(
                    label: 'Defesa',
                    value: player.defense,
                    icon: Icons.shield_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _AttributeTile(
                    label: 'F\u00F4lego',
                    value: player.stamina,
                    icon: Icons.bolt_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OverallBadge extends StatelessWidget {
  const _OverallBadge({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
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
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'OVR',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '$value',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
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

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.label,
    this.isPosition = false,
  });

  final IconData icon;
  final String label;
  final bool isPosition;

  @override
  Widget build(BuildContext context) {
    final style = isPosition ? positionVisualStyle(label) : null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
          Icon(icon, size: 14, color: isPosition ? style!.foreground : AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isPosition ? style!.foreground : Colors.white.withValues(alpha: 0.78),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardActionButton extends StatelessWidget {
  const _CardActionButton({
    required this.icon,
    required this.onTap,
    this.isDanger = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final color =
        isDanger ? AppColors.danger : Colors.white.withValues(alpha: 0.74);

    return _PressableScale(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

class _AttributeTile extends StatelessWidget {
  const _AttributeTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primary.withValues(alpha: 0.90)),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.54),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumFab extends StatelessWidget {
  const _PremiumFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF34D46A),
              Color(0xFF169A49),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.30),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF14191B),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.58),
                fontSize: 14,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.canGoBack,
    required this.canGoForward,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentPage;
  final int totalPages;
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14191B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 360;

          if (isCompact) {
            return Column(
              children: [
                Text(
                  'Pagina $currentPage de $totalPages',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _PaginationButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        label: 'Anterior',
                        enabled: canGoBack,
                        onTap: onPrevious,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PaginationButton(
                        icon: Icons.arrow_forward_ios_rounded,
                        label: 'Proxima',
                        enabled: canGoForward,
                        onTap: onNext,
                        alignEnd: true,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                flex: 3,
                child: _PaginationButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  label: 'Anterior',
                  enabled: canGoBack,
                  onTap: onPrevious,
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Pagina $currentPage de $totalPages',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: _PaginationButton(
                  icon: Icons.arrow_forward_ios_rounded,
                  label: 'Proxima',
                  enabled: canGoForward,
                  onTap: onNext,
                  alignEnd: true,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PaginationButton extends StatelessWidget {
  const _PaginationButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    this.alignEnd = false,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.42,
      child: _PressableScale(
        onTap: enabled ? onTap : () {},
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            mainAxisAlignment:
                alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!alignEnd) ...[
                Icon(icon, color: Colors.white, size: 16),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (alignEnd) ...[
                const SizedBox(width: 8),
                Icon(icon, color: Colors.white, size: 16),
              ],
            ],
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
      scale: _isPressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: widget.borderRadius,
          splashColor: Colors.white.withValues(alpha: 0.08),
          highlightColor: Colors.white.withValues(alpha: 0.03),
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
