import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

class DivideTimeApp extends StatelessWidget {
  const DivideTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Divide Time',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}