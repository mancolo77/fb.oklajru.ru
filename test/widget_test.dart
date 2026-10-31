import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_/models/quiz_models.dart';
import 'package:app_/screens/main_navigation_screen.dart';
import 'package:app_/screens/quiz_play_screen.dart';
import 'package:app_/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'loyalty_coins': 800,
      'loyalty_points': 450,
      'quizzes_played': 2,
      'words_solved': 1,
    });
  });

  Widget createTestApp(Widget child) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: child,
    );
  }

  testWidgets('Verifies 4 bottom navigation tabs are present and clickable (Russian)',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const MainNavigationScreen()));
    await tester.pumpAndSettle();

    // Verify 4 navigation tabs in Russian
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Матч-центр'), findsOneWidget);
    expect(find.text('Арена слов'), findsOneWidget);
    expect(find.text('Задания'), findsOneWidget);
    expect(find.text('Фан-клуб'), findsOneWidget);

    // Switch to Арена слов tab
    await tester.tap(find.text('Арена слов'));
    await tester.pumpAndSettle();
    expect(find.text('Арена футбольных слов'), findsOneWidget);

    // Switch to Задания tab
    await tester.tap(find.text('Задания'));
    await tester.pumpAndSettle();
    expect(find.text('Ежедневные задания'), findsOneWidget);

    // Switch to Фан-клуб tab
    await tester.tap(find.text('Фан-клуб'));
    await tester.pumpAndSettle();
    expect(find.text('Фан-клуб РПЛ'), findsOneWidget);
    expect(find.text('Магазин наград'), findsOneWidget);

    // Switch back to Матч-центр tab
    await tester.tap(find.text('Матч-центр'));
    await tester.pumpAndSettle();
    expect(find.text('Матч-Центр РПЛ'), findsOneWidget);

    // Zero overflow exceptions
    expect(tester.takeException(), isNull);
  });

  testWidgets('Zero RenderFlex overflow on small screen (320x568)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestApp(const MainNavigationScreen()));
    await tester.pumpAndSettle();

    // Test tab switching on small screen
    await tester.tap(find.text('Арена слов'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Задания'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Фан-клуб'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Матч-центр'));
    await tester.pumpAndSettle();

    // Verify no RenderFlex overflow
    expect(tester.takeException(), isNull);
  });

  testWidgets('Zero RenderFlex overflow on standard screen (390x844)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestApp(const MainNavigationScreen()));
    await tester.pumpAndSettle();

    // Scroll down on Матч-центр
    await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -300));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Фан-клуб'));
    await tester.pumpAndSettle();

    // Scroll down in Фан-клуб
    await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('Zero RenderFlex overflow on tablet screen (768x1024)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(768, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestApp(const MainNavigationScreen()));
    await tester.pumpAndSettle();

    for (final tab in ['Арена слов', 'Задания', 'Фан-клуб', 'Матч-центр']) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
    }

    expect(tester.takeException(), isNull);
  });

  testWidgets('QuizPlayScreen renders properly and answers questions without overflow',
      (WidgetTester tester) async {
    final sampleCategory = QuizCategory(
      id: 'test_category',
      title: 'Тактика и история',
      description: 'Описание тестовой категории',
      icon: 'sports_soccer',
      colorHex: '#E21A22',
      questions: [
        QuizQuestion(
          id: 1,
          question: 'Какой клуб выиграл чемпионат России в 1992 году?',
          options: ['ЦСКА Москва', 'Спартак Москва', 'Динамо Москва', 'Зенит'],
          correctIndex: 1,
          explanation: 'Спартак Москва доминировал в начале 1990-х под руководством Олега Романцева.',
          points: 100,
        ),
      ],
    );

    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestApp(QuizPlayScreen(category: sampleCategory)));
    await tester.pumpAndSettle();

    expect(find.text('Вопрос 1 из 1'), findsOneWidget);
    expect(find.text('Спартак Москва'), findsOneWidget);

    // Select the correct option
    await tester.tap(find.text('Спартак Москва'));
    await tester.pumpAndSettle();

    expect(find.text('Верное решение!'), findsOneWidget);
    expect(find.text('Результаты квиза'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });
}
