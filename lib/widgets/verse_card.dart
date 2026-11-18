import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/verse.dart';

class VerseCard extends StatelessWidget {
  final Verse verse;
  final VoidCallback onBookmarkToggle;
  final VoidCallback? onNextVerse;

  const VerseCard({
    super.key,
    required this.verse,
    required this.onBookmarkToggle,
    this.onNextVerse,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('verse_card'),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade900,
              Colors.deepPurple.shade600,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    verse.translation,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('bookmark_button'),
                  icon: Icon(
                    verse.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: verse.isBookmarked ? Colors.amber.shade400 : Colors.white70,
                    size: 28,
                  ),
                  onPressed: onBookmarkToggle,
                  tooltip: verse.isBookmarked ? 'Remove Bookmark' : 'Bookmark Verse',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Icon(
              Icons.format_quote_rounded,
              color: Colors.amber.shade400.withOpacity(0.6),
              size: 36,
            ),
            const SizedBox(height: 8),
            Text(
              verse.text,
              key: const Key('verse_text'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                height: 1.5,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  verse.reference,
                  key: const Key('verse_reference'),
                  style: TextStyle(
                    color: Colors.amber.shade300,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, color: Colors.white70, size: 20),
                      tooltip: 'Copy Verse',
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: '"${verse.text}" - ${verse.reference} (${verse.translation})'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Verse copied to clipboard!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    if (onNextVerse != null)
                      IconButton(
                        key: const Key('next_verse_button'),
                        icon: const Icon(Icons.shuffle_rounded, color: Colors.amber, size: 24),
                        tooltip: 'Random Verse',
                        onPressed: onNextVerse,
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
