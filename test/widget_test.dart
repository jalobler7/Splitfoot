import 'dart:io';

import 'package:divide_time/app/app.dart';
import 'package:divide_time/app/routes/app_routes.dart';
import 'package:divide_time/data/models/player_model.dart';
import 'package:divide_time/data/models/team_group_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory hiveTestDir;

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const DivideTimeApp());
    await tester.pump();
  }

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    hiveTestDir = await Directory.systemTemp.createTemp('splitfoot_test_');
    Hive.init(hiveTestDir.path);

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PlayerModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TeamGroupModelAdapter());
    }

    await Hive.openBox<PlayerModel>('players');
    await Hive.openBox<TeamGroupModel>('team_groups');
  });

  setUp(() async {
    await Hive.box<PlayerModel>('players').clear();
    await Hive.box<TeamGroupModel>('team_groups').clear();
    appRouter.go(AppRoutes.home);
  });

  tearDownAll(() async {
    await Hive.close();
    if (await hiveTestDir.exists()) {
      await hiveTestDir.delete(recursive: true);
    }
  });

  testWidgets('app starts correctly in the test environment', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('Montar Partida'), findsOneWidget);
    expect(find.text('\u00A9 2026 Splitfoot'), findsOneWidget);
  });

  testWidgets('footer is displayed only on the home page', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('\u00A9 2026 Splitfoot'), findsOneWidget);
    expect(find.text('Pol\u00EDtica de Privacidade'), findsOneWidget);
    expect(find.text('Termos de Uso'), findsOneWidget);

    await tester.tap(find.text('Pol\u00EDtica de Privacidade'));
    await tester.pumpAndSettle();

    expect(find.text('PRIVACIDADE E DADOS'), findsOneWidget);
    expect(find.text('Armazenamento local'), findsOneWidget);
    expect(find.text('\u00A9 2026 Splitfoot'), findsNothing);
    expect(find.text('Termos de Uso'), findsNothing);

    appRouter.go(AppRoutes.matchSetup);
    await tester.pumpAndSettle();

    expect(find.text('Montar Partida'), findsOneWidget);
    expect(find.text('\u00A9 2026 Splitfoot'), findsNothing);
    expect(find.text('Pol\u00EDtica de Privacidade'), findsNothing);
    expect(find.text('Termos de Uso'), findsNothing);
  });

  testWidgets('main routes open their expected pages', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    appRouter.go(AppRoutes.players);
    await tester.pumpAndSettle();
    expect(find.text('Jogadores'), findsOneWidget);

    appRouter.go(AppRoutes.rankings);
    await tester.pumpAndSettle();
    expect(find.text('Rankings'), findsOneWidget);

    appRouter.go(AppRoutes.help);
    await tester.pumpAndSettle();
    expect(find.text('Como funciona o ranking'), findsOneWidget);
  });
}
