import 'package:flutter_test/flutter_test.dart';
import 'package:serve_cafe_mobile/main.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(const ServeCafeApp());
    expect(find.text('Serve Cafe'), findsWidgets);
  });
}
