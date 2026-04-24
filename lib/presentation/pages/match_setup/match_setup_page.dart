import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/enums/balance_mode.dart';
import '../../../core/enums/sport_type.dart';
import '../../../data/datasources/player_local_datasource.dart';
import '../../../data/models/player_model.dart';
import '../../../domain/entities/team_result.dart';
import '../../../domain/services/team_balance_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  final TextEditingController _teamAController = TextEditingController(text: '5');
  final TextEditingController _teamBController = TextEditingController(text: '5');
  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadPlayers();
    _searchController.addListener(_onSearchChanged);
  }

  void _loadPlayers() {
    final players = _dataSource.getAllPlayers();

    setState(() {
      _allPlayers = players;
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchText = _searchController.text.trim().toLowerCase();
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
        return 'Overall medio';
      case BalanceMode.attributes:
        return 'Atributos';
      case BalanceMode.positions:
        return 'Posicoes';
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
      _searchController.clear();
      _searchText = '';
    });
  }

  int _expectedTotalPlayers() {
    final teamA = int.tryParse(_teamAController.text) ?? 0;
    final teamB = int.tryParse(_teamBController.text) ?? 0;
    return teamA + teamB;
  }

  int _selectedCount() {
    return _selectedPlayers.length;
  }

  String _selectionStatusText() {
    final selected = _selectedCount();
    final expected = _expectedTotalPlayers();

    if (expected <= 0) {
      return 'Defina a quantidade de jogadores dos times';
    }

    if (selected == expected) {
      return 'Selecionados: $selected de $expected';
    }

    if (selected < expected) {
      final missing = expected - selected;
      return 'Selecionados: $selected de $expected - Faltam $missing';
    }

    final extra = selected - expected;
    return 'Selecionados: $selected de $expected - Excedeu $extra';
  }

  Color _selectionStatusColor(BuildContext context) {
    final selected = _selectedCount();
    final expected = _expectedTotalPlayers();
    final colorScheme = Theme.of(context).colorScheme;

    if (expected <= 0) {
      return colorScheme.outline;
    }

    if (selected == expected) {
      return Colors.green;
    }

    if (selected < expected) {
      return Colors.orange;
    }

    return Colors.red;
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
          content: Text('Quantidade de jogadores nao bate com os times'),
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
      List<TeamResult> results;

      switch (_balanceMode) {
        case BalanceMode.overallAverage:
          results = _teamBalanceService.balanceTopByOverall(
            players: selectedPlayersList,
            teamASize: teamA,
            teamBSize: teamB,
            limit: 5,
          );
          break;
        case BalanceMode.attributes:
          results = _teamBalanceService.balanceTopByAttributes(
            players: selectedPlayersList,
            teamASize: teamA,
            teamBSize: teamB,
            limit: 5,
          );
          break;
        case BalanceMode.positions:
          results = _teamBalanceService.balanceTopByPosition(
            players: selectedPlayersList,
            teamASize: teamA,
            teamBSize: teamB,
            sport: _selectedSport,
            limit: 5,
          );
          break;
      }

      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhuma opcao de escalacao foi encontrada'),
          ),
        );
        return;
      }

      context.push(AppRoutes.result, extra: results);
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
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sportPlayers = _allPlayers
        .where((player) => player.sport == _sportKey(_selectedSport))
        .toList();

    final visiblePlayers = sportPlayers.where((player) {
      if (_searchText.isEmpty) return true;
      return player.name.toLowerCase().contains(_searchText);
    }).toList();

    final selectionColor = _selectionStatusColor(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0B1510),
              AppColors.background,
              Color(0xFF0D1117),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              children: [
                _SimpleHeader(
                  onBack: () => context.go(AppRoutes.home),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF111618).withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 28,
                          offset: Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: _SectionSurface(
                              child: Column(
                                children: [
                                  const _SectionLabel(
                                    title: 'Configuracao',
                                    subtitle: 'Defina o esporte, o modo de divisao e o tamanho de cada time.',
                                  ),
                                  const SizedBox(height: 14),
                                  _PremiumDropdown<SportType>(
                                    value: _selectedSport,
                                    label: 'Esporte',
                                    leadingIcon: Icons.sports_soccer_rounded,
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
                                  _PremiumDropdown<BalanceMode>(
                                    value: _balanceMode,
                                    label: 'Modo de divisao',
                                    leadingIcon: Icons.tune_rounded,
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
                                        child: _PremiumTextField(
                                          controller: _teamAController,
                                          label: 'Time A',
                                          icon: Icons.groups_2_rounded,
                                          keyboardType: TextInputType.number,
                                          onChanged: (_) => setState(() {}),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _PremiumTextField(
                                          controller: _teamBController,
                                          label: 'Time B',
                                          icon: Icons.groups_2_rounded,
                                          keyboardType: TextInputType.number,
                                          onChanged: (_) => setState(() {}),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 14)),
                          SliverToBoxAdapter(
                            child: _SectionSurface(
                              child: Column(
                                children: [
                                  _PremiumTextField(
                                    controller: _searchController,
                                    label: 'Buscar atleta por nome',
                                    icon: Icons.search_rounded,
                                    suffixIcon: _searchText.isNotEmpty
                                        ? IconButton(
                                            onPressed: () => _searchController.clear(),
                                            icon: Icon(
                                              Icons.close_rounded,
                                              color: Colors.white.withValues(alpha: 0.64),
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(height: 12),
                                  _SelectionStatusCard(
                                    text: _selectionStatusText(),
                                    color: selectionColor,
                                    selectedCount: _selectedCount(),
                                    expectedCount: _expectedTotalPlayers(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 14)),
                          SliverToBoxAdapter(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Jogadores de ${_sportLabel(_selectedSport)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${visiblePlayers.length} disponiveis',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.56),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _InfoBadge(
                                  icon: Icons.how_to_reg_rounded,
                                  label: '${_selectedCount()} selecionados',
                                ),
                              ],
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 12)),
                          if (sportPlayers.isEmpty)
                            const SliverToBoxAdapter(
                              child: _EmptyState(
                                icon: Icons.groups_outlined,
                                title: 'Nenhum jogador cadastrado para este esporte',
                                subtitle: 'Cadastre atletas antes de montar a partida.',
                              ),
                            )
                          else if (visiblePlayers.isEmpty)
                            const SliverToBoxAdapter(
                              child: _EmptyState(
                                icon: Icons.search_off_rounded,
                                title: 'Nenhum jogador encontrado',
                                subtitle: 'Ajuste a busca para localizar atletas.',
                              ),
                            )
                          else
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final itemIndex = index ~/ 2;
                                  if (index.isOdd) {
                                    return const SizedBox(height: 10);
                                  }

                                  final player = visiblePlayers[itemIndex];
                                  final isSelected = _selectedPlayers.contains(player.id);

                                  return _SelectablePlayerCard(
                                    player: player,
                                    isSelected: isSelected,
                                    onTap: () => _togglePlayer(player.id),
                                  );
                                },
                                childCount: visiblePlayers.isEmpty ? 0 : visiblePlayers.length * 2 - 1,
                              ),
                            ),
                          const SliverToBoxAdapter(child: SizedBox(height: 12)),
                          SliverToBoxAdapter(
                            child: _PrimaryActionButton(
                              label: 'Gerar Times',
                              icon: Icons.auto_awesome_rounded,
                              onTap: _generateTeams,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SimpleHeader extends StatelessWidget {
  const _SimpleHeader({
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconSurfaceButton(
          icon: Icons.arrow_back_rounded,
          onTap: onBack,
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Text(
            'Montar Partida',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionSurface extends StatelessWidget {
  const _SectionSurface({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.56),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _PremiumDropdown<T> extends StatelessWidget {
  const _PremiumDropdown({
    required this.value,
    required this.label,
    required this.leadingIcon,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final String label;
  final IconData leadingIcon;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      dropdownColor: const Color(0xFF151A1C),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Colors.white.withValues(alpha: 0.66),
      ),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: _premiumInputDecoration(
        label: label,
        icon: leadingIcon,
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}

class _PremiumTextField extends StatelessWidget {
  const _PremiumTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.onChanged,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: _premiumInputDecoration(
        label: label,
        icon: icon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

InputDecoration _premiumInputDecoration({
  required String label,
  required IconData icon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(
      color: Colors.white.withValues(alpha: 0.62),
      fontWeight: FontWeight.w500,
    ),
    prefixIcon: Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Icon(
        icon,
        color: Colors.white.withValues(alpha: 0.62),
        size: 20,
      ),
    ),
    prefixIconConstraints: const BoxConstraints(minWidth: 46, minHeight: 46),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: const Color(0xFF141A1D),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.72), width: 1.4),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
    ),
  );
}

class _SelectionStatusCard extends StatelessWidget {
  const _SelectionStatusCard({
    required this.text,
    required this.color,
    required this.selectedCount,
    required this.expectedCount,
  });

  final String text;
  final Color color;
  final int selectedCount;
  final int expectedCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.fact_check_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$selectedCount confirmados - meta $expectedCount',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.54),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectablePlayerCard extends StatelessWidget {
  const _SelectablePlayerCard({
    required this.player,
    required this.isSelected,
    required this.onTap,
  });

  final PlayerModel player;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isSelected
                  ? AppColors.primary.withValues(alpha: 0.16)
                  : const Color(0xFF161C1F),
              const Color(0xFF111618),
            ],
          ),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.44)
                : Colors.white.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.14)
                  : const Color(0x1A000000),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _PremiumCheckbox(value: isSelected),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoBadge(
                          icon: Icons.shield_outlined,
                          label: player.position,
                        ),
                        _InfoBadge(
                          icon: Icons.workspace_premium_rounded,
                          label: 'Overall ${player.overall}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumCheckbox extends StatelessWidget {
  const _PremiumCheckbox({
    required this.value,
  });

  final bool value;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        gradient: value
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF34D46A),
                  Color(0xFF169A49),
                ],
              )
            : null,
        color: value ? null : Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          color: value
              ? AppColors.primary.withValues(alpha: 0.88)
              : Colors.white.withValues(alpha: 0.14),
        ),
      ),
      child: value
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
          : null,
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
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
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconSurfaceButton extends StatelessWidget {
  const _IconSurfaceButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Center(
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
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
        width: double.infinity,
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
