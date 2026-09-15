import 'package:flutter_test/flutter_test.dart';
import 'package:lingoread/main.dart';
import 'package:lingoread/providers/reading_provider.dart';
import 'package:lingoread/providers/vocabulary_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('LingoReadApp loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => VocabularyProvider()),
          ChangeNotifierProvider(create: (_) => ReadingProvider()),
        ],
        child: const LingoReadApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Gazete Oku'), findsOneWidget);
    expect(find.text('Hikayeler'), findsOneWidget);
    expect(find.text('Kelime Haznem'), findsOneWidget);
  });
}
