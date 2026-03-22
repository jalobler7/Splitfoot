import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajuda'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.go(AppRoutes.home);
          },
        ),
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle('Sobre o app'),
              SizedBox(height: 8),
              Text(
                'O Splitfoot ajuda a montar times equilibrados de forma rapida. '
                'Primeiro, cadastre seus jogadores. Depois, em "Montar Partida", '
                'escolha o esporte, selecione os atletas e defina quantos jogadores '
                'cada time tera. Ao clicar em "Gerar Times", o app calcula as melhores combinacoes.',
              ),
              SizedBox(height: 24),
              _SectionTitle('Tipos de divisao'),
              SizedBox(height: 8),
              _ModeTitle('Divisao por overall medio'),
              SizedBox(height: 4),
              Text(
                'Busca equilibrar a media geral de habilidade entre os dois times.',
              ),
              SizedBox(height: 12),
              _ModeTitle('Divisao por atributos'),
              SizedBox(height: 4),
              Text(
                'Compara os jogadores por atributos para distribuir forças de forma mais detalhada.',
              ),
              SizedBox(height: 12),
              _ModeTitle('Divisao por posicoes'),
              SizedBox(height: 4),
              Text(
                'Respeita as posicoes dos jogadores e, ao mesmo tempo, tenta manter o equilibrio tecnico entre os times.',
              ),
              SizedBox(height: 24),
              _SectionTitle('Dicas de uso'),
              SizedBox(height: 8),
              Text(
                '- Use a busca para encontrar jogadores mais rapido.\n'
                '- Preencha a posicao correta de cada atleta para melhorar a divisao por posicoes.\n'
                '- Evite diferenca entre total selecionado e tamanho dos times, porque o app exige numeros exatos.\n'
                '- Se nao aparecer resultado, revise quantidade de jogadores e modo escolhido.',
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _ModeTitle extends StatelessWidget {
  const _ModeTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
