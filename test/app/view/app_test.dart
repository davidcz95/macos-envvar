import 'package:flutter_test/flutter_test.dart';
import 'package:macos_envvar/app/app.dart';
import 'package:macos_envvar/features/dashboard/dashboard.dart';

void main() {
  group('App', () {
    testWidgets('renders CounterPage', (tester) async {
      await tester.pumpWidget(const App());
      expect(find.byType(DashboardPage), findsOneWidget);
    });
  });
}
