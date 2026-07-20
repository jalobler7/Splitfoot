import 'package:divide_time/app/app.dart';
import 'package:divide_time/app/routes/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('footer is displayed only on the home page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DivideTimeApp());

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
}
