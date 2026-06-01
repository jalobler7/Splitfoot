import 'package:divide_time/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('global footer opens the privacy policy', (
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
  });
}
