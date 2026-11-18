import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/verse.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message ${statusCode != null ? '(Code: $statusCode)' : ''}';
}

class ApiService {
  final http.Client client;
  final String baseUrl;

  static const List<String> popularVerses = [
    'john 3:16',
    'philippians 4:13',
    'psalm 23:1',
    'jeremiah 29:11',
    'proverbs 3:5',
    'romans 8:28',
    'isaiah 40:31',
    'matthew 6:33',
    '1 corinthians 13:4',
    'psalm 46:10',
    'joshua 1:9',
    '2 timothy 1:7',
    'romans 12:2',
    'galatians 5:22',
    'ephesians 2:8',
  ];

  ApiService({
    http.Client? client,
    this.baseUrl = 'https://bible-api.com',
  }) : client = client ?? http.Client();

  /// Fetches the Daily Verse from REST API.
  /// Uses a deterministic daily verse rotation based on day of year, or fetches specified verse.
  Future<Verse> fetchDailyVerse([String? passage]) async {
    try {
      final selectedPassage = passage ?? _getPassageForToday();
      final uri = Uri.parse('$baseUrl/${Uri.encodeComponent(selectedPassage)}');

      final response = await client.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw ApiException('Connection timed out. Please check your network connection.');
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Verse.fromJson(data);
      } else if (response.statusCode == 444 || response.statusCode == 404) {
        throw ApiException('Requested verse not found.', response.statusCode);
      } else {
        throw ApiException(
          'Failed to load verse from server.',
          response.statusCode,
        );
      }
    } on SocketException {
      throw ApiException('No Internet connection available.');
    } on FormatException {
      throw ApiException('Invalid response format received from API server.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Fetches a random verse from popular curated passages
  Future<Verse> fetchRandomVerse() async {
    final randomIndex = DateTime.now().millisecondsSinceEpoch % popularVerses.length;
    return fetchDailyVerse(popularVerses[randomIndex]);
  }

  /// Helper to get a consistent daily verse passage based on the current day of year
  String _getPassageForToday() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final index = dayOfYear % popularVerses.length;
    return popularVerses[index];
  }
}
