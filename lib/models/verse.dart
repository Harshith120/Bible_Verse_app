class Verse {
  final String id;
  final String book;
  final int chapter;
  final int verseNumber;
  final String text;
  final String translation;
  final String dateFetched;
  final bool isBookmarked;

  const Verse({
    required this.id,
    required this.book,
    required this.chapter,
    required this.verseNumber,
    required this.text,
    this.translation = 'WEB',
    required this.dateFetched,
    this.isBookmarked = false,
  });

  /// Reference formatted as "Book Chapter:Verse" (e.g. "John 3:16")
  String get reference => '$book $chapter:$verseNumber';

  /// Factory constructor to create a Verse model from API JSON response
  /// Supports https://bible-api.com API format
  factory Verse.fromJson(Map<String, dynamic> json) {
    // Handle bible-api.com format with 'verses' array
    if (json.containsKey('verses') && (json['verses'] is List) && (json['verses'] as List).isNotEmpty) {
      final firstVerse = json['verses'][0];
      final bookName = (firstVerse['book_name'] ?? json['reference'] ?? 'Bible').toString();
      final chap = firstVerse['chapter'] is int
          ? firstVerse['chapter'] as int
          : int.tryParse(firstVerse['chapter']?.toString() ?? '1') ?? 1;
      final ver = firstVerse['verse'] is int
          ? firstVerse['verse'] as int
          : int.tryParse(firstVerse['verse']?.toString() ?? '1') ?? 1;

      return Verse(
        id: '${bookName}_${chap}_$ver',
        book: bookName,
        chapter: chap,
        verseNumber: ver,
        text: (json['text'] as String? ?? '').trim(),
        translation: (json['translation_name'] as String? ?? 'WEB').toUpperCase(),
        dateFetched: DateTime.now().toIso8601String().split('T')[0],
        isBookmarked: false,
      );
    }

    // Direct JSON format or fallback
    final book = (json['book'] ?? 'John').toString();
    final chap = json['chapter'] is int ? json['chapter'] as int : int.tryParse(json['chapter']?.toString() ?? '3') ?? 3;
    final ver = json['verse'] is int ? json['verse'] as int : int.tryParse(json['verse']?.toString() ?? '16') ?? 16;

    return Verse(
      id: json['id'] as String? ?? '${book}_${chap}_$ver',
      book: book,
      chapter: chap,
      verseNumber: ver,
      text: (json['text'] as String? ?? '').trim(),
      translation: (json['translation'] as String? ?? 'WEB').toUpperCase(),
      dateFetched: json['dateFetched'] as String? ?? DateTime.now().toIso8601String().split('T')[0],
      isBookmarked: json['isBookmarked'] == 1 || json['isBookmarked'] == true,
    );
  }

  /// Converts Verse to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book': book,
      'chapter': chapter,
      'verse': verseNumber,
      'text': text,
      'translation': translation,
      'dateFetched': dateFetched,
      'isBookmarked': isBookmarked,
    };
  }

  /// Converts Verse object to Map suitable for SQLite storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book': book,
      'chapter': chapter,
      'verse_number': verseNumber,
      'text': text,
      'translation': translation,
      'date_fetched': dateFetched,
      'is_bookmarked': isBookmarked ? 1 : 0,
    };
  }

  /// Creates a Verse from SQLite Map
  factory Verse.fromMap(Map<String, dynamic> map) {
    return Verse(
      id: map['id'] as String,
      book: map['book'] as String,
      chapter: map['chapter'] as int,
      verseNumber: map['verse_number'] as int,
      text: map['text'] as String,
      translation: map['translation'] as String? ?? 'WEB',
      dateFetched: map['date_fetched'] as String,
      isBookmarked: (map['is_bookmarked'] as int? ?? 0) == 1,
    );
  }

  /// Copy method for creating modified instances
  Verse copyWith({
    String? id,
    String? book,
    int? chapter,
    int? verseNumber,
    String? text,
    String? translation,
    String? dateFetched,
    bool? isBookmarked,
  }) {
    return Verse(
      id: id ?? this.id,
      book: book ?? this.book,
      chapter: chapter ?? this.chapter,
      verseNumber: verseNumber ?? this.verseNumber,
      text: text ?? this.text,
      translation: translation ?? this.translation,
      dateFetched: dateFetched ?? this.dateFetched,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Verse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          book == other.book &&
          chapter == other.chapter &&
          verseNumber == other.verseNumber &&
          text == other.text &&
          translation == other.translation &&
          isBookmarked == other.isBookmarked;

  @override
  int get hashCode =>
      id.hashCode ^
      book.hashCode ^
      chapter.hashCode ^
      verseNumber.hashCode ^
      text.hashCode ^
      translation.hashCode ^
      isBookmarked.hashCode;
}
