import 'package:divide_time/app/routes/app_routes.dart';
import 'package:divide_time/app/theme/app_colors.dart';
import 'package:divide_time/widgets/developer_credit_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      _HeroSection(theme: theme),
                      const SizedBox(height: 28),
                      _PrimaryActionButton(
                        icon: Icons.sports_soccer_rounded,
                        label: 'Montar Partida',
                        onTap: () => context.go(AppRoutes.matchSetup),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _SecondaryActionButton(
                              icon: Icons.groups_rounded,
                              label: 'Jogadores',
                              onTap: () => context.go(AppRoutes.players),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SecondaryActionButton(
                              icon: Icons.leaderboard_rounded,
                              label: 'Rankings',
                              onTap: () => context.go(AppRoutes.rankings),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _SecondaryActionButton(
                        icon: Icons.help_outline_rounded,
                        label: 'Ajuda',
                        balanceTrailingSpace: true,
                        onTap: () => context.go(AppRoutes.help),
                      ),
                      const SizedBox(height: 24),
                      const DeveloperCreditWidget(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
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
              'FUTEBOL AMADOR',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: AppColors.primary.withValues(alpha: 0.14),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
                ),
                child: const Icon(
                  Icons.sports_soccer_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Splitfoot',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    height: 1,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Monte times equilibrados em segundos',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              height: 1.35,
              color: AppColors.textSecondary,
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
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.balanceTrailingSpace = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool balanceTrailingSpace;

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFF151A1C),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              if (balanceTrailingSpace) const SizedBox(width: 46),
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
      scale: _isPressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: widget.borderRadius,
          splashColor: Colors.white.withValues(alpha: 0.08),
          highlightColor: Colors.white.withValues(alpha: 0.03),
          onHighlightChanged: (value) {
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
