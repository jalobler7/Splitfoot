import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:divide_time/widgets/developer_credit_widget.dart';
import '../../../app/routes/app_routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Splitfoot'),
        actions: [
          IconButton(
            onPressed: () => context.go(AppRoutes.help),
            icon: const Icon(Icons.help_outline),
            tooltip: 'Ajuda',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
              child: IntrinsicHeight(
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
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.go(AppRoutes.rankings),
                      child: const Text('Rankings'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => context.go(AppRoutes.help),
                      icon: const Icon(Icons.help),
                      label: const Text('Ajuda'),
                    ),
                    const Spacer(),
                    const DeveloperCreditWidget(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
