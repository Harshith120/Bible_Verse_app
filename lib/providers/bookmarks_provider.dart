import 'package:flutter/foundation.dart';
import '../models/verse.dart';
import '../repositories/verse_repository.dart';

class BookmarksProvider with ChangeNotifier {
  final VerseRepository repository;

  List<Verse> _bookmarks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Verse> get bookmarks => List.unmodifiable(_bookmarks);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  BookmarksProvider({VerseRepository? repository})
      : repository = repository ?? VerseRepository();

  /// Loads all bookmarked verses from SQLite
  Future<void> loadBookmarks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _bookmarks = await repository.getBookmarks();
    } catch (e) {
      _errorMessage = 'Failed to load bookmarks from storage.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Removes bookmark for specified verse
  Future<void> removeBookmark(Verse verse) async {
    try {
      await repository.toggleBookmark(verse);
      _bookmarks.removeWhere((b) => b.id == verse.id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to remove bookmark.';
      notifyListeners();
    }
  }
}
