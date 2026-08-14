import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/performance/performance_probe.dart';
import 'data/models/team_group_model.dart';
import 'data/services/app_data_migration_service.dart';
import 'data/models/player_model.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const traceAllRebuilds = bool.fromEnvironment('SPLITFOOT_TRACE_ALL_REBUILDS');
  if (kDebugMode && traceAllRebuilds) {
    debugPrintRebuildDirtyWidgets = true;
  }
  PerformanceProbe.install();

  await Hive.initFlutter();

  Hive.registerAdapter(PlayerModelAdapter());
  Hive.registerAdapter(TeamGroupModelAdapter());

  await Hive.openBox<PlayerModel>('players');
  await Hive.openBox<TeamGroupModel>('team_groups');
  await AppDataMigrationService().ensureGroupsMigration();

  runApp(const DivideTimeApp());
}
