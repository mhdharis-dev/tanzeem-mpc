import 'package:flutter_test/flutter_test.dart';
import 'package:tanzeem_meelad_coordinator/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TanzeemApp());
    expect(find.byType(TanzeemApp), findsOneWidget);
  });
}
