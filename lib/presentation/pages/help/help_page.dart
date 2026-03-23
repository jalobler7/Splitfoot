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
                'O Splitfoot ajuda você a montar times equilibrados de forma rápida. '
                    'Primeiro, cadastre seus jogadores. Depois, em "Montar Partida", '
                    'escolha o esporte, selecione os atletas e defina quantos jogadores '
                    'cada time terá. Ao clicar em "Gerar Times", o app calcula as melhores combinações.',
              ),

              SizedBox(height: 24),

              _SectionTitle('Tipos de divisão'),
              SizedBox(height: 8),

              _ModeTitle('Divisão por overall médio'),
              SizedBox(height: 4),
              Text(
                'Busca equilibrar a média geral de habilidade entre os dois times.',
              ),

              SizedBox(height: 12),

              _ModeTitle('Divisão por atributos'),
              SizedBox(height: 4),
              Text(
                'Compara os times com base em múltiplos atributos, distribuindo as forças de forma mais detalhada.',
              ),

              SizedBox(height: 12),

              _ModeTitle('Divisão por posições'),
              SizedBox(height: 4),
              Text(
                'Respeita as posições dos jogadores e, ao mesmo tempo, tenta manter o equilíbrio técnico entre os times.',
              ),

              SizedBox(height: 24),

              _SectionTitle('Atributos dos jogadores'),
              SizedBox(height: 8),
              Text(
                'Os atributos devem ser definidos de 0 a 99 e representam as principais características de cada jogador. '
                    'Preencher corretamente esses valores é essencial para gerar times mais equilibrados.',
              ),

              SizedBox(height: 12),

              _ModeTitle('Ataque'),
              SizedBox(height: 4),
              Text(
                'Considere a qualidade de chute, finalização, drible e outras características ofensivas do jogador.',
              ),

              SizedBox(height: 12),

              _ModeTitle('Defesa'),
              SizedBox(height: 4),
              Text(
                'Considere a qualidade de marcação, dividida, posicionamento e outras características defensivas.',
              ),

              SizedBox(height: 12),

              _ModeTitle('Fôlego'),
              SizedBox(height: 4),
              Text(
                'Considere a resistência física do jogador, incluindo fôlego, velocidade, capacidade de correr por longos períodos e outras características físicas.',
              ),

              SizedBox(height: 24),

              _SectionTitle('Dicas de uso'),
              SizedBox(height: 8),
              Text(
                '- Use a busca para encontrar jogadores mais rapidamente.\n'
                    '- Preencha corretamente a posição de cada atleta para melhorar a divisão por posições.\n'
                    '- Evite diferenças entre o total de jogadores selecionados e o tamanho dos times, pois o app exige números exatos.\n'
                    '- Caso não apareça nenhum resultado, revise a quantidade de jogadores e o modo escolhido.',
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