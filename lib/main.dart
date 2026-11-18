import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/bookmarks_provider.dart';
import 'providers/verse_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/verse_repository.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization skipped or failed: $e');
  }

  runApp(const DailyVerseApp());
}

class DailyVerseApp extends StatelessWidget {
  final VerseRepository? verseRepository;
  final AuthRepository? authRepository;

  const DailyVerseApp({
    super.key,
    this.verseRepository,
    this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveVerseRepo = verseRepository ?? VerseRepository();
    final effectiveAuthRepo = authRepository ?? AuthRepository();

    return MultiProvider(
      providers: [
        Provider<VerseRepository>.value(value: effectiveVerseRepo),
        Provider<AuthRepository>.value(value: effectiveAuthRepo),
        ChangeNotifierProvider<VerseProvider>(
          create: (_) => VerseProvider(repository: effectiveVerseRepo),
        ),
        ChangeNotifierProvider<BookmarksProvider>(
          create: (_) => BookmarksProvider(repository: effectiveVerseRepo),
        ),
        ChangeNotifierProvider<AppAuthProvider>(
          create: (_) => AppAuthProvider(repository: effectiveAuthRepo),
        ),
      ],
      child: MaterialApp(
        title: 'Daily Bible Verse',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            primary: Colors.deepPurple,
            secondary: Colors.amber,
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppAuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.status == AuthStatus.uninitialized) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            ),
          );
        }

        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
