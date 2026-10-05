import 'package:flutter_test/flutter_test.dart';
import 'package:chess_master/main.dart';

void main() {
  testWidgets('App smoke test launches HomeScreen with v2 modes', (WidgetTester tester) async {
    await tester.pumpWidget(const ChessMasterApp());
    await tester.pumpAndSettle();

    expect(find.text('CHESS MASTER'), findsOneWidget);
    expect(find.text('VS COMPUTER'), findsOneWidget);
    expect(find.text('LOCAL 2 PLAYERS'), findsOneWidget);
    expect(find.text('MITTENS'), findsOneWidget);
  });
}
