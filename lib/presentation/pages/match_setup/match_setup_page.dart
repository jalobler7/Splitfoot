import 'package:flutter/material.dart';

class MatchSetupPage extends StatelessWidget {
  const MatchSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Montar Partida'),
      ),
      body: const Center(
        child: Text('Tela de montagem da partida'),
      ),
    );
  }
}