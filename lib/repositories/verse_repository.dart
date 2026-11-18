import '../models/verse.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';

class VerseRepository {
  final ApiService apiService;
  final DatabaseHelper dbHelper;

  VerseRepository({
    ApiService? apiService,
    DatabaseHelper? dbHelper,
  })  : apiService = apiService ?? ApiService(),
        dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Fetches daily verse with cache-first and API-fallback architecture.
  /// If [forceRefresh] is true, ignores cache and fetches from API.
  Future<Verse> getDailyVerse({bool forceRefresh = false}) async {
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    // Check local SQLite cache first if not forcing refresh
    if (!forceRefresh) {
      try {
        final cachedVerse = await dbHelper.getCachedVerseByDate(todayStr);
        if (cachedVerse != null) {
          final isBookmarked = await dbHelper.isVerseBookmarked(cachedVerse.id);
          return cachedVerse.copyWith(isBookmarked: isBookmarked);
        }
      } catch (_) {
        // Continue to API if local cache read fails
      }
    }

    // Attempt REST API call
    try {
      final verse = await apiService.fetchDailyVerse();
      final isBookmarked = await dbHelper.isVerseBookmarked(verse.id);
      final updatedVerse = verse.copyWith(
        dateFetched: todayStr,
        isBookmarked: isBookmarked,
      );

      // Cache the verse in SQLite for offline access
      await dbHelper.cacheVerse(updatedVerse);
      return updatedVerse;
    } on ApiException catch (e) {
      // API call failed, try loading any previously cached verse from SQLite
      final fallbackVerse = await dbHelper.getLatestCachedVerse();
      if (fallbackVerse != null) {
        return fallbackVerse;
      }
      // If no cached verse exists, rethrow API exception for UI error handling
      rethrow;
    } catch (e) {
      final fallbackVerse = await dbHelper.getLatestCachedVerse();
      if (fallbackVerse != null) {
        return fallbackVerse;
      }
      throw ApiException('Unable to retrieve verse: ${e.toString()}');
    }
  }

  /// Fetches a new random verse from REST API
  Future<Verse> getRandomVerse() async {
    try {
      final verse = await apiService.fetchRandomVerse();
      final isBookmarked = await dbHelper.isVerseBookmarked(verse.id);
      return verse.copyWith(isBookmarked: isBookmarked);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch random verse: ${e.toString()}');
    }
  }

  /// Toggles bookmark state for a verse in SQLite database
  Future<Verse> toggleBookmark(Verse verse) async {
    final newBookmarkStatus = !verse.isBookmarked;
    final updatedVerse = verse.copyWith(isBookmarked: newBookmarkStatus);

    if (newBookmarkStatus) {
      await dbHelper.addBookmark(updatedVerse);
    } else {
      await dbHelper.removeBookmark(verse.id);
    }

    return updatedVerse;
  }

  /// Retrieves all bookmarked verses from SQLite
  Future<List<Verse>> getBookmarks() async {
    return await dbHelper.getAllBookmarks();
  }
}
