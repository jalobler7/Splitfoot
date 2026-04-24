import 'package:divide_time/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  static const List<_HelpSectionData> _sections = [
    _HelpSectionData(
      title: 'Como funciona',
      icon: Icons.auto_awesome_rounded,
      description:
          'O Splitfoot organiza seus jogadores, calcula notas e gera combinações mais equilibradas para partidas de futebol amador.',
      bullets: [
        'Cadastre os atletas com ataque, defesa, fôlego, posição e esporte.',
        'Escolha o formato da partida e selecione os jogadores disponíveis.',
        'Gere os times para comparar equilíbrio e desempenho antes de jogar.',
      ],
    ),
    _HelpSectionData(
      title: 'Como montar partida',
      icon: Icons.sports_soccer_rounded,
      description:
          'Na tela principal, toque em "Montar Partida" para definir esporte, jogadores ativos, tamanho dos times e modo de divisão.',
      bullets: [
        'Use a seleção correta de atletas para evitar sobra ou falta de jogadores.',
        'Prefira preencher posições para melhorar a divisão por função em campo.',
        'Revise o resultado e gere novamente se quiser testar outro critério.',
      ],
    ),
    _HelpSectionData(
      title: 'Como cadastrar jogadores',
      icon: Icons.groups_rounded,
      description:
          'A tela de jogadores concentra o cadastro, edição e organização dos atletas usados nas partidas e rankings.',
      bullets: [
        'Defina nome, posição e modalidade correta para cada atleta.',
        'Preencha os atributos de 0 a 99 com o maximo de critério possível.',
        'Manter dados consistentes melhora muito a qualidade dos times gerados.',
      ],
    ),
    _HelpSectionData(
      title: 'Como funciona ranking',
      icon: Icons.leaderboard_rounded,
      description:
          'Os rankings destacam os melhores jogadores por esporte e categoria com base nos atributos cadastrados.',
      bullets: [
        'O ranking geral usa a nota overall como base principal.',
        'Categorias ofensivas, defensivas e físicaas leem cada atributo separadamente.',
      ],
    ),
    _HelpSectionData(
      title: 'Dúvidas frequentes',
      icon: Icons.quiz_rounded,
      description:
          'As respostas abaixo resolvem as perguntas mais comuns sobre uso, edição e equilíbrio dos times.',
      bullets: [
        'Se algo não bater, revise os dados do jogador antes de gerar os times novamente.',
        'Resultados diferentes podem acontecer ao trocar o modo de divisão.',
      ],
    ),
    _HelpSectionData(
      title: 'Sobre o app',
      icon: Icons.info_outline_rounded,
      description:
          'Splitfoot foi pensado para deixar a organização da pelada mais rápida, justa e com leitura clara no celular.',
      bullets: [
        'Visual premium com foco em desempenho e confiança.',
        'Fluxo simples para cadastrar, montar partida e acompanhar rankings.',
      ],
    ),
  ];

  static const List<_FaqItemData> _faqItems = [
    _FaqItemData(
      question: 'Como montar times equilibrados?',
      answer:
          'Cadastre os jogadores com atributos realistas, selecione a quantidade exata de atletas para a partida e use o modo de divisão que melhor combina com o contexto do jogo.',
    ),
    _FaqItemData(
      question: 'Posso editar jogadores depois?',
      answer:
          'Sim. A tela de jogadores permite ajustar nome, posição, modalidade e atributos sempre que voce quiser refinar os dados.',
    ),
    _FaqItemData(
      question: 'Como o ranking é calculado?',
      answer:
          'O ranking geral considera o overall do jogador.',
    ),
    _FaqItemData(
      question: 'Quantos jogadores posso cadastrar?',
      answer:
          'Não há limite prático para uso comum. O ideal e manter a base organizada para facilitar busca, seleção e leitura dos rankings.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
            tooltip: 'Voltar',
            onTap: () {
              if (context.canPop()) {
                context.pop();
                return;
              }
              context.go(AppRoutes.home);
            },
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
          child: LayoutBuilder(
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
                      children: const [
                        _HelpHeroCard(),
                        SizedBox(height: 24),
                        _SectionsGrid(sections: _sections),
                        SizedBox(height: 24),
                        _FaqSection(items: _faqItems),
                        SizedBox(height: 24),
                        _AboutFooterCard(),
                      ],
                    ),
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
          'Ajuda',
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

class _HelpHeroCard extends StatelessWidget {
  const _HelpHeroCard();

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
                  'GUIA RAPIDO',
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
                  Icons.help_outline_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Tudo que voce precisa para usar o Splitfoot com mais clareza e rapidez.',
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
            'Encontre orientações sobre cadastro, montagem de partidas, rankings e respostas para as dúvidas mais comuns em um fluxo simples de consultar.',
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
            children: const [
              _OverviewBadge(icon: Icons.menu_book_rounded, label: 'Guia por sseções'),
              _OverviewBadge(icon: Icons.flash_on_rounded, label: 'Leitura rápida'),
              _OverviewBadge(icon: Icons.verified_rounded, label: 'Uso com confiança'),
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
          Text(
            label,
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

class _SectionsGrid extends StatelessWidget {
  const _SectionsGrid({
    required this.sections,
  });

  final List<_HelpSectionData> sections;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Guia por seções',
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
              children: sections
                  .map(
                    (section) => SizedBox(
                      width: itemWidth,
                      child: _HelpSectionCard(section: section),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _HelpSectionCard extends StatelessWidget {
  const _HelpSectionCard({
    required this.section,
  });

  final _HelpSectionData section;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF13181A),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(section.icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  section.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            section.description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 16),
          ...section.bullets.map(
            (bullet) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      bullet,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqSection extends StatelessWidget {
  const _FaqSection({
    required this.items,
  });

  final List<_FaqItemData> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111719),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.forum_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Perguntas frequentes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Abra cada resposta para entender rapidamente como o app se comporta no uso real.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          ...List.generate(
            items.length,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: index == items.length - 1 ? 0 : 12),
              child: _FaqTile(item: items[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({
    required this.item,
  });

  final _FaqItemData item;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            iconColor: AppColors.primary,
            collapsedIconColor: Colors.white.withValues(alpha: 0.72),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            title: Text(
              item.question,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            children: [
              Text(
                item.answer,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutFooterCard extends StatelessWidget {
  const _AboutFooterCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF13181A),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Sobre este produto',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 16),
          _MetaRow(
            icon: Icons.verified_rounded,
            label: 'Versão do app',
            value: '1.0.0',
          ),
          SizedBox(height: 12),
          _MetaRow(
            icon: Icons.person_rounded,
            label: 'Desenvolvido por',
            value: 'Joao Lobler',
          ),
          SizedBox(height: 12),
          _MetaRow(
            icon: Icons.code_rounded,
            label: 'GitHub / contato',
            value: 'github.com/joaolobler',
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ],
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

class _HelpSectionData {
  const _HelpSectionData({
    required this.title,
    required this.icon,
    required this.description,
    required this.bullets,
  });

  final String title;
  final IconData icon;
  final String description;
  final List<String> bullets;
}

class _FaqItemData {
  const _FaqItemData({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;
}
