import 'package:bible_verse_app/models/verse.dart';
import 'package:bible_verse_app/repositories/verse_repository.dart';
import 'package:bible_verse_app/services/api_service.dart';
import 'package:bible_verse_app/services/database_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<ApiService>(),
  MockSpec<DatabaseHelper>(),
])
import 'verse_repository_test.mocks.dart';

void main() {
  late MockApiService mockApiService;
  late MockDatabaseHelper mockDatabaseHelper;
  late VerseRepository verseRepository;

  final sampleVerse = Verse(
    id: 'John_3_16',
    book: 'John',
    chapter: 3,
    verseNumber: 16,
    text: 'For God so loved the world...',
    translation: 'WEB',
    dateFetched: DateTime.now().toIso8601String().split('T')[0],
    isBookmarked: false,
  );

  setUp(() {
    mockApiService = MockApiService();
    mockDatabaseHelper = MockDatabaseHelper();
    verseRepository = VerseRepository(
      apiService: mockApiService,
      dbHelper: mockDatabaseHelper,
    );
  });

  group('VerseRepository Unit Tests', () {
    test('getDailyVerse fetches from API and caches to database when cache is empty', () async {
      when(mockDatabaseHelper.getCachedVerseByDate(any)).thenAnswer((_) async => null);
      when(mockApiService.fetchDailyVerse()).thenAnswer((_) async => sampleVerse);
      when(mockDatabaseHelper.isVerseBookmarked(any)).thenAnswer((_) async => false);

      final result = await verseRepository.getDailyVerse(forceRefresh: true);

      expect(result.book, 'John');
      expect(result.chapter, 3);
      expect(result.verseNumber, 16);
      verify(mockApiService.fetchDailyVerse()).called(1);
      verify(mockDatabaseHelper.cacheVerse(any)).called(1);
    });

    test('getDailyVerse returns cached verse from database if available', () async {
      when(mockDatabaseHelper.getCachedVerseByDate(any)).thenAnswer((_) async => sampleVerse);
      when(mockDatabaseHelper.isVerseBookmarked(any)).thenAnswer((_) async => false);

      final result = await verseRepository.getDailyVerse(forceRefresh: false);

      expect(result.book, 'John');
      verifyNever(mockApiService.fetchDailyVerse());
    });

    test('getDailyVerse falls back to latest cached verse when API fails', () async {
      when(mockDatabaseHelper.getCachedVerseByDate(any)).thenAnswer((_) async => null);
      when(mockApiService.fetchDailyVerse()).thenThrow(ApiException('No Network'));
      when(mockDatabaseHelper.getLatestCachedVerse()).thenAnswer((_) async => sampleVerse);
      when(mockDatabaseHelper.isVerseBookmarked(any)).thenAnswer((_) async => false);

      final result = await verseRepository.getDailyVerse(forceRefresh: true);

      expect(result.book, 'John');
      verify(mockDatabaseHelper.getLatestCachedVerse()).called(1);
    });

    test('toggleBookmark adds bookmark when verse is not bookmarked', () async {
      final unbookmarkedVerse = sampleVerse.copyWith(isBookmarked: false);
      when(mockDatabaseHelper.addBookmark(any)).thenAnswer((_) async {});

      final updatedVerse = await verseRepository.toggleBookmark(unbookmarkedVerse);

      expect(updatedVerse.isBookmarked, isTrue);
      verify(mockDatabaseHelper.addBookmark(any)).called(1);
    });

    test('toggleBookmark removes bookmark when verse is already bookmarked', () async {
      final bookmarkedVerse = sampleVerse.copyWith(isBookmarked: true);
      when(mockDatabaseHelper.removeBookmark(any)).thenAnswer((_) async {});

      final updatedVerse = await verseRepository.toggleBookmark(bookmarkedVerse);

      expect(updatedVerse.isBookmarked, isFalse);
      verify(mockDatabaseHelper.removeBookmark(bookmarkedVerse.id)).called(1);
    });
  });
}
