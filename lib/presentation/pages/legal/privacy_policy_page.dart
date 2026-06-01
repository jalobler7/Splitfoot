import 'package:flutter/material.dart';

import 'legal_document_page.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentPage(
      title: 'Política de Privacidade',
      eyebrow: 'PRIVACIDADE E DADOS',
      icon: Icons.shield_outlined,
      introduction:
          'Esta política explica como o Splitfoot lida com as informações cadastradas durante o uso da plataforma.',
      sections: [
        LegalSectionData(
          title: 'Armazenamento local',
          paragraphs: [
            'Os dados de atletas e grupos são armazenados localmente no navegador ou dispositivo do usuário por meio do Hive.',
            'Essas informações não são enviadas para servidores próprios do Splitfoot.',
          ],
        ),
        LegalSectionData(
          title: 'Responsabilidade pelos dados',
          paragraphs: [
            'O usuário é responsável pela manutenção e pelo armazenamento local dos dados cadastrados.',
            'A limpeza de cache ou dos dados do navegador, a troca de navegador ou a limpeza do dispositivo podem causar a perda definitiva das informações armazenadas.',
          ],
        ),
        LegalSectionData(
          title: 'Cookies e publicidade',
          paragraphs: [
            'No futuro, o Splitfoot poderá utilizar serviços de publicidade, como o Google AdSense.',
            'Cookies e tecnologias semelhantes poderão ser utilizados para melhorar a experiência de uso e exibir anúncios relevantes.',
          ],
        ),
        LegalSectionData(
          title: 'Atualizações desta política',
          paragraphs: [
            'Esta Política de Privacidade poderá ser atualizada para refletir melhorias na plataforma ou mudanças nos recursos utilizados.',
          ],
        ),
      ],
    );
  }
}
