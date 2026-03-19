import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/models/player_model.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(PlayerModelAdapter());

  await Hive.openBox<PlayerModel>('players');

  runApp(const DivideTimeApp());
}