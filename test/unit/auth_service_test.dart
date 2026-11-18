import 'package:bible_verse_app/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthException Unit Tests', () {
    test('AuthException stores message and code correctly', () {
      final exception = AuthException('Invalid email address', 'invalid-email');
      expect(exception.message, 'Invalid email address');
      expect(exception.code, 'invalid-email');
      expect(exception.toString(), contains('invalid-email'));
    });
  });
}
