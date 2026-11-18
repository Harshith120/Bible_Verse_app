package com.example.bible_verse_app.db

data class VerseItem(
    val id: Long = 0,
    val text: String,
    val reference: String,
    val translation: String = "WEB",
    val dateFetched: String = "",
    val isBookmarked: Boolean = false
)
