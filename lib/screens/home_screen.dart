import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/verse_provider.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/verse_card.dart';
import 'bookmarks_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<VerseProvider>(context, listen: false);
      if (provider.verse == null) {
        provider.fetchDailyVerse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final verseProvider = Provider.of<VerseProvider>(context);
    final authProvider = Provider.of<AppAuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daily Bible Verse',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            key: const Key('bookmarks_nav_button'),
            icon: const Icon(Icons.bookmarks_rounded),
            tooltip: 'Bookmarked Verses',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BookmarksScreen(),
                ),
              );
            },
          ),
          IconButton(
            key: const Key('logout_button'),
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: () => authProvider.signOut(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => verseProvider.fetchDailyVerse(forceRefresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - kToolbarHeight - MediaQuery.of(context).padding.top,
            ),
            child: _buildBody(verseProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(VerseProvider verseProvider) {
    switch (verseProvider.status) {
      case VerseStatus.loading:
      case VerseStatus.initial:
        return const LoadingIndicator();

      case VerseStatus.error:
        return ErrorView(
          message: verseProvider.errorMessage ?? 'An error occurred loading today\'s verse.',
          onRetry: () => verseProvider.fetchDailyVerse(forceRefresh: true),
        );

      case VerseStatus.success:
        final verse = verseProvider.verse;
        if (verse == null) {
          return ErrorView(
            message: 'No verse available.',
            onRetry: () => verseProvider.fetchDailyVerse(forceRefresh: true),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Verse of the Day',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.deepPurple.shade900,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
              ),
              const SizedBox(height: 12),
              VerseCard(
                verse: verse,
                onBookmarkToggle: () => verseProvider.toggleBookmark(),
                onNextVerse: () => verseProvider.fetchRandomVerse(),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                key: const Key('refresh_verse_button'),
                onPressed: () => verseProvider.fetchDailyVerse(forceRefresh: true),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Refresh Daily Verse'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade50,
                  foregroundColor: Colors.deepPurple,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}
