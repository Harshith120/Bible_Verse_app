import 'package:bible_verse_app/models/verse.dart';
import 'package:bible_verse_app/widgets/verse_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const testVerse = Verse(
    id: 'John_3_16',
    book: 'John',
    chapter: 3,
    verseNumber: 16,
    text: 'For God so loved the world, that he gave his one and only Son.',
    translation: 'WEB',
    dateFetched: '2025-01-01',
    isBookmarked: false,
  );

  testWidgets('VerseCard renders verse text, reference and translation tag', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VerseCard(
            verse: testVerse,
            onBookmarkToggle: () {},
          ),
        ),
      ),
    );

    expect(find.text('For God so loved the world, that he gave his one and only Son.'), findsOneWidget);
    expect(find.text('John 3:16'), findsOneWidget);
    expect(find.text('WEB'), findsOneWidget);
    expect(find.byKey(const Key('bookmark_button')), findsOneWidget);
  });

  testWidgets('Tapping bookmark button invokes onBookmarkToggle callback', (WidgetTester tester) async {
    bool toggled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VerseCard(
            verse: testVerse,
            onBookmarkToggle: () {
              toggled = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('bookmark_button')));
    await tester.pump();

    expect(toggled, isTrue);
  });
}
