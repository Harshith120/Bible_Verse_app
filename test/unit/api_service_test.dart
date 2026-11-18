import 'dart:convert';
import 'package:bible_verse_app/services/api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<http.Client>()])
import 'api_service_test.mocks.dart';

void main() {
  late MockClient mockHttpClient;
  late ApiService apiService;

  setUp(() {
    mockHttpClient = MockClient();
    apiService = ApiService(client: mockHttpClient);
  });

  group('ApiService Unit Tests', () {
    const mockVerseJson = '''
    {
      "reference": "John 3:16",
      "verses": [
        {
          "book_id": "JHN",
          "book_name": "John",
          "chapter": 3,
          "verse": 16,
          "text": "For God so loved the world, that he gave his one and only Son..."
        }
      ],
      "text": "For God so loved the world, that he gave his one and only Son...",
      "translation_id": "web",
      "translation_name": "World English Bible",
      "translation_note": "Public Domain"
    }
    ''';

    test('fetchDailyVerse returns Verse model on 200 HTTP response', () async {
      when(mockHttpClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(mockVerseJson, 200));

      final verse = await apiService.fetchDailyVerse('john 3:16');

      expect(verse.book, 'John');
      expect(verse.chapter, 3);
      expect(verse.verseNumber, 16);
      expect(verse.reference, 'John 3:16');
      expect(verse.text, contains('For God so loved the world'));
    });

    test('fetchDailyVerse throws ApiException on 404 HTTP response', () async {
      when(mockHttpClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(
        () => apiService.fetchDailyVerse('invalid 99:99'),
        throwsA(isA<ApiException>()),
      );
    });

    test('fetchDailyVerse throws ApiException on 500 server error', () async {
      when(mockHttpClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('Server Error', 500));

      expect(
        () => apiService.fetchDailyVerse(),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
