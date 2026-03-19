import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes/app_routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Divide Time'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.players),
              child: const Text('Jogadores'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.matchSetup),
              child: const Text('Montar Partida'),
            ),
          ],
        ),
      ),
    );
  }
}