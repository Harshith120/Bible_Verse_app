import 'package:flutter/foundation.dart';
import '../models/verse.dart';
import '../repositories/verse_repository.dart';
import '../services/api_service.dart';

enum VerseStatus { initial, loading, success, error }

class VerseProvider with ChangeNotifier {
  final VerseRepository repository;

  VerseStatus _status = VerseStatus.initial;
  Verse? _verse;
  String? _errorMessage;

  VerseStatus get status => _status;
  Verse? get verse => _verse;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == VerseStatus.loading;
  bool get isError => _status == VerseStatus.error;

  VerseProvider({VerseRepository? repository})
      : repository = repository ?? VerseRepository();

  /// Fetches daily verse with loading and error handling
  Future<void> fetchDailyVerse({bool forceRefresh = false}) async {
    _status = VerseStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _verse = await repository.getDailyVerse(forceRefresh: forceRefresh);
      _status = VerseStatus.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = VerseStatus.error;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred while fetching verse.';
      _status = VerseStatus.error;
    } finally {
      notifyListeners();
    }
  }

  /// Fetches a random verse from API
  Future<void> fetchRandomVerse() async {
    _status = VerseStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _verse = await repository.getRandomVerse();
      _status = VerseStatus.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = VerseStatus.error;
    } catch (e) {
      _errorMessage = 'Failed to fetch random verse.';
      _status = VerseStatus.error;
    } finally {
      notifyListeners();
    }
  }

  /// Toggles bookmark for currently displayed verse
  Future<void> toggleBookmark() async {
    if (_verse == null) return;

    try {
      final updatedVerse = await repository.toggleBookmark(_verse!);
      _verse = updatedVerse;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update bookmark.';
      notifyListeners();
    }
  }
}
