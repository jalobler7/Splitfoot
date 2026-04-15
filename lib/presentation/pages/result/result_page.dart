import 'package:divide_time/app/routes/app_routes.dart';
import 'package:divide_time/app/theme/app_colors.dart';
import 'package:divide_time/core/utils/team_share_action.dart';
import 'package:divide_time/data/models/player_model.dart';
import 'package:divide_time/domain/entities/team_result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  Future<void> _handleShareOrCopyCurrentResult() async {
    await handleShareOrCopy(
      context,
      teamA: _currentResult.teamA,
      teamB: _currentResult.teamB,
      title: _shareTitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final results = widget.results;

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
                _ResultHeader(
                  theme: theme,
                  currentIndex: _currentIndex,
                  totalResults: results.length,
                  onBack: () => context.go(AppRoutes.home),
                  onShare: _handleShareOrCopyCurrentResult,
                ),
                const SizedBox(height: 16),
                _SectionSurface(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Opcao ${_currentIndex + 1} de ${results.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          _InfoBadge(
                            icon: Icons.balance_rounded,
                            label: _currentResult.scoreLabel,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 42,
                        child: ListView.separated(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: results.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final isSelected = index == _currentIndex;

                            return _PageChip(
                              label: 'Opcao ${index + 1}',
                              selected: isSelected,
                              onTap: () => _goToPage(index),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
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
                        padding: const EdgeInsets.only(bottom: 8),
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
                            _ScoreSummaryCard(
                              label: result.scoreLabel,
                              value: result.score is double
                                  ? (result.score as double).toStringAsFixed(2)
                                  : result.score.toString(),
                              overallDifference: result.overallDifference.toStringAsFixed(2),
                            ),
                            const SizedBox(height: 16),
                            _AttributeComparisonCard(result: result),
                            const SizedBox(height: 16),
                            _ActionRow(
                              onShare: _handleShareOrCopyCurrentResult,
                              onRanking: () {
                                final allPlayers = [
                                  ...result.teamA,
                                  ...result.teamB,
                                ];

                                context.push(
                                  AppRoutes.ranking,
                                  extra: allPlayers,
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
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

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({
    required this.theme,
    required this.currentIndex,
    required this.totalResults,
    required this.onBack,
    required this.onShare,
  });

  final ThemeData theme;
  final int currentIndex;
  final int totalResults;
  final VoidCallback onBack;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF17231D),
            Color(0xFF101915),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconSurfaceButton(
            icon: Icons.arrow_back_rounded,
            onTap: onBack,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                  ),
                  child: const Text(
                    'RESULTADO PREMIUM',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.05,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Divisao de Times',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Compare rapidamente as melhores combinacoes geradas e escolha a opcao mais equilibrada.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.66),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _InfoBadge(
                      icon: Icons.view_carousel_rounded,
                      label: '${currentIndex + 1} de $totalResults',
                    ),
                    _InfoBadge(
                      icon: kIsWeb ? Icons.copy_rounded : Icons.share_rounded,
                      label: kIsWeb ? 'Copiar' : 'Compartilhar',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _TopActionButton(
            icon: kIsWeb ? Icons.copy_rounded : Icons.share_rounded,
            label: kIsWeb ? 'Copiar' : 'Compartilhar',
            onTap: onShare,
          ),
        ],
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({
    required this.title,
    required this.average,
    required this.players,
  });

  final String title;
  final double average;
  final List<PlayerModel> players;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
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
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Media ${average.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.58),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _OverallBadge(value: average.toStringAsFixed(2)),
              ],
            ),
            const SizedBox(height: 16),
            ...players.map(
              (player) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PlayerRow(player: player),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({
    required this.player,
  });

  final PlayerModel player;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                '${player.overall}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  player.position,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.56),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'OVR ${player.overall}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.70),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreSummaryCard extends StatelessWidget {
  const _ScoreSummaryCard({
    required this.label,
    required this.value,
    required this.overallDifference,
  });

  final String label;
  final String value;
  final String overallDifference;

  @override
  Widget build(BuildContext context) {
    return _SectionSurface(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
              height: 1,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Diferenca geral',
                  value: overallDifference,
                  icon: Icons.compare_arrows_rounded,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: _MetricTile(
                  label: 'Leitura',
                  value: 'Rapida',
                  icon: Icons.visibility_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttributeComparisonCard extends StatelessWidget {
  const _AttributeComparisonCard({
    required this.result,
  });

  final TeamResult result;

  @override
  Widget build(BuildContext context) {
    return _SectionSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comparativo de atributos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 14),
          _ComparisonRow(
            label: 'Ataque',
            teamAValue: '${result.teamAAttackTotal}',
            teamBValue: '${result.teamBAttackTotal}',
          ),
          const SizedBox(height: 10),
          _ComparisonRow(
            label: 'Defesa',
            teamAValue: '${result.teamADefenseTotal}',
            teamBValue: '${result.teamBDefenseTotal}',
          ),
          const SizedBox(height: 10),
          _ComparisonRow(
            label: 'Folego',
            teamAValue: '${result.teamAStaminaTotal}',
            teamBValue: '${result.teamBStaminaTotal}',
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
            ),
            child: Text(
              'Diferenca total: ${result.attributeDifferenceScore}',
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

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.onShare,
    required this.onRanking,
  });

  final VoidCallback onShare;
  final VoidCallback onRanking;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GhostActionButton(
            icon: kIsWeb ? Icons.copy_rounded : Icons.share_rounded,
            label: kIsWeb ? 'Copiar' : 'Compartilhar',
            onTap: onShare,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PrimaryActionButton(
            icon: Icons.leaderboard_rounded,
            label: 'Ver Ranking',
            onTap: onRanking,
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
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF13181A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PageChip extends StatelessWidget {
  const _PageChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF34D46A),
                    Color(0xFF169A49),
                  ],
                )
              : null,
          color: selected ? null : Colors.white.withValues(alpha: 0.04),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.56),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.label,
    required this.teamAValue,
    required this.teamBValue,
  });

  final String label;
  final String teamAValue;
  final String teamBValue;

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
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '$teamAValue x $teamBValue',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverallBadge extends StatelessWidget {
  const _OverallBadge({
    required this.value,
  });

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF34D46A),
            Color(0xFF169A49),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'MEDIA',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
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
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Ink(
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
              color: AppColors.primary.withValues(alpha: 0.28),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GhostActionButton extends StatelessWidget {
  const _GhostActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF14191B),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopActionButton extends StatelessWidget {
  const _TopActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
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
