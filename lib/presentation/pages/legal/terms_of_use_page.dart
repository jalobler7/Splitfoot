import 'package:flutter/material.dart';

import 'legal_document_page.dart';

class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentPage(
      title: 'Termos de Uso',
      eyebrow: 'CONDIÇÕES DE UTILIZAÇÃO',
      icon: Icons.description_outlined,
      introduction:
          'Ao utilizar o Splitfoot, o usuário declara estar ciente das condições apresentadas nestes Termos de Uso.',
      sections: [
        LegalSectionData(
          title: 'Finalidade da plataforma',
          paragraphs: [
            'O Splitfoot é uma ferramenta para organização de atletas e sorteio equilibrado de equipes.',
            'O usuário é responsável pelas informações cadastradas e pela forma como utiliza os resultados gerados.',
          ],
        ),
        LegalSectionData(
          title: 'Disponibilidade',
          paragraphs: [
            'Não existe garantia de disponibilidade contínua da plataforma. Recursos podem ser alterados, suspensos ou descontinuados futuramente.',
          ],
        ),
        LegalSectionData(
          title: 'Armazenamento e perda de dados',
          paragraphs: [
            'Os dados cadastrados são armazenados localmente no navegador ou dispositivo do usuário.',
            'O Splitfoot não se responsabiliza por perda de dados causada por limpeza de cache, troca de dispositivo, troca de navegador ou falhas do navegador.',
          ],
        ),
        LegalSectionData(
          title: 'Direitos da plataforma',
          paragraphs: [
            'Os direitos relacionados à plataforma, sua identidade e seus recursos pertencem aos responsáveis pelo Splitfoot.',
          ],
        ),
        LegalSectionData(
          title: 'Atualizações dos termos',
          paragraphs: [
            'Estes Termos de Uso poderão ser atualizados futuramente. A versão publicada na plataforma será considerada a versão vigente.',
          ],
        ),
      ],
    );
  }
}
