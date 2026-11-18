import 'package:bible_verse_app/models/verse.dart';
import 'package:bible_verse_app/providers/auth_provider.dart';
import 'package:bible_verse_app/providers/bookmarks_provider.dart';
import 'package:bible_verse_app/providers/verse_provider.dart';
import 'package:bible_verse_app/repositories/auth_repository.dart';
import 'package:bible_verse_app/repositories/verse_repository.dart';
import 'package:bible_verse_app/screens/home_screen.dart';
import 'package:bible_verse_app/services/api_service.dart';
import 'package:bible_verse_app/services/auth_service.dart';
import 'package:bible_verse_app/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

@GenerateNiceMocks([
  MockSpec<ApiService>(),
  MockSpec<DatabaseHelper>(),
  MockSpec<AuthService>(),
])
import 'home_screen_test.mocks.dart';

void main() {
  late MockApiService mockApiService;
  late MockDatabaseHelper mockDatabaseHelper;
  late MockAuthService mockAuthService;
  late VerseRepository verseRepository;
  late AuthRepository authRepository;

  const sampleVerse = Verse(
    id: 'John_3_16',
    book: 'John',
    chapter: 3,
    verseNumber: 16,
    text: 'For God so loved the world...',
    translation: 'WEB',
    dateFetched: '2025-01-01',
    isBookmarked: false,
  );

  setUp(() {
    mockApiService = MockApiService();
    mockDatabaseHelper = MockDatabaseHelper();
    mockAuthService = MockAuthService();

    verseRepository = VerseRepository(
      apiService: mockApiService,
      dbHelper: mockDatabaseHelper,
    );
    authRepository = AuthRepository(authService: mockAuthService);
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        Provider<VerseRepository>.value(value: verseRepository),
        Provider<AuthRepository>.value(value: authRepository),
        ChangeNotifierProvider<VerseProvider>(
          create: (_) => VerseProvider(repository: verseRepository),
        ),
        ChangeNotifierProvider<BookmarksProvider>(
          create: (_) => BookmarksProvider(repository: verseRepository),
        ),
        ChangeNotifierProvider<AppAuthProvider>(
          create: (_) => AppAuthProvider(repository: authRepository),
        ),
      ],
      child: const MaterialApp(
        home: HomeScreen(),
      ),
    );
  }

  testWidgets('HomeScreen displays verse card when verse is loaded successfully', (WidgetTester tester) async {
    when(mockDatabaseHelper.getCachedVerseByDate(any)).thenAnswer((_) async => sampleVerse);
    when(mockDatabaseHelper.isVerseBookmarked(any)).thenAnswer((_) async => false);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Verse of the Day'), findsOneWidget);
    expect(find.byKey(const Key('verse_card')), findsOneWidget);
    expect(find.text('John 3:16'), findsOneWidget);
    expect(find.text('For God so loved the world...'), findsOneWidget);
  });

  testWidgets('HomeScreen displays ErrorView on API error with no cache', (WidgetTester tester) async {
    when(mockDatabaseHelper.getCachedVerseByDate(any)).thenAnswer((_) async => null);
    when(mockApiService.fetchDailyVerse()).thenThrow(ApiException('No Connection'));
    when(mockDatabaseHelper.getLatestCachedVerse()).thenAnswer((_) async => null);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Oops! Something went wrong'), findsOneWidget);
    expect(find.byKey(const Key('retry_button')), findsOneWidget);
  });
}
