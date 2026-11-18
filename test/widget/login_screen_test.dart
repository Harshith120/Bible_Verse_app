import 'package:bible_verse_app/providers/auth_provider.dart';
import 'package:bible_verse_app/repositories/auth_repository.dart';
import 'package:bible_verse_app/screens/login_screen.dart';
import 'package:bible_verse_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';

@GenerateNiceMocks([MockSpec<AuthService>()])
import 'login_screen_test.mocks.dart';

void main() {
  late MockAuthService mockAuthService;
  late AuthRepository authRepository;

  setUp(() {
    mockAuthService = MockAuthService();
    authRepository = AuthRepository(authService: mockAuthService);
  });

  testWidgets('LoginScreen shows validation errors for empty inputs', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthRepository>.value(value: authRepository),
          ChangeNotifierProvider<AppAuthProvider>(
            create: (_) => AppAuthProvider(repository: authRepository),
          ),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Verify initial elements
    expect(find.text('Daily Bible Verse'), findsOneWidget);
    expect(find.byKey(const Key('email_field')), findsOneWidget);
    expect(find.byKey(const Key('password_field')), findsOneWidget);
    expect(find.byKey(const Key('login_button')), findsOneWidget);

    // Tap login button without entering values
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pump();

    // Verify validation error messages appear
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });
}
