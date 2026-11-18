package com.example.bible_verse_app.db

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

class BibleDatabaseHelper(context: Context) :
    SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {

    companion object {
        private const val DATABASE_NAME = "bible_verse_native.db"
        private const val DATABASE_VERSION = 1

        private const val TABLE_CACHED = "cached_verses"
        private const val TABLE_BOOKMARKS = "bookmarks"

        private const val COL_ID = "id"
        private const val COL_TEXT = "text"
        private const val COL_REF = "reference"
        private const val COL_TRANSLATION = "translation"
        private const val COL_DATE = "date_fetched"
    }

    override fun onCreate(db: SQLiteDatabase) {
        val createCachedTable = """
            CREATE TABLE $TABLE_CACHED (
                $COL_ID INTEGER PRIMARY KEY AUTOINCREMENT,
                $COL_TEXT TEXT NOT NULL,
                $COL_REF TEXT NOT NULL,
                $COL_TRANSLATION TEXT NOT NULL,
                $COL_DATE TEXT NOT NULL
            )
        """.trimIndent()

        val createBookmarksTable = """
            CREATE TABLE $TABLE_BOOKMARKS (
                $COL_ID INTEGER PRIMARY KEY AUTOINCREMENT,
                $COL_TEXT TEXT NOT NULL,
                $COL_REF TEXT UNIQUE NOT NULL,
                $COL_TRANSLATION TEXT NOT NULL,
                $COL_DATE TEXT NOT NULL
            )
        """.trimIndent()

        db.execSQL(createCachedTable)
        db.execSQL(createBookmarksTable)
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        db.execSQL("DROP TABLE IF EXISTS $TABLE_CACHED")
        db.execSQL("DROP TABLE IF EXISTS $TABLE_BOOKMARKS")
        onCreate(db)
    }

    fun cacheVerse(verse: VerseItem) {
        val db = writableDatabase
        val values = ContentValues().apply {
            put(COL_TEXT, verse.text)
            put(COL_REF, verse.reference)
            put(COL_TRANSLATION, verse.translation)
            put(COL_DATE, verse.dateFetched)
        }
        db.insert(TABLE_CACHED, null, values)
    }

    fun addBookmark(verse: VerseItem): Boolean {
        val db = writableDatabase
        val values = ContentValues().apply {
            put(COL_TEXT, verse.text)
            put(COL_REF, verse.reference)
            put(COL_TRANSLATION, verse.translation)
            put(COL_DATE, verse.dateFetched)
        }
        val result = db.insertWithOnConflict(
            TABLE_BOOKMARKS,
            null,
            values,
            SQLiteDatabase.CONFLICT_REPLACE
        )
        return result != -1L
    }

    fun removeBookmark(reference: String): Boolean {
        val db = writableDatabase
        return db.delete(TABLE_BOOKMARKS, "$COL_REF = ?", arrayOf(reference)) > 0
    }

    fun isVerseBookmarked(reference: String): Boolean {
        val db = readableDatabase
        val cursor = db.query(
            TABLE_BOOKMARKS,
            arrayOf(COL_ID),
            "$COL_REF = ?",
            arrayOf(reference),
            null, null, null
        )
        val exists = cursor.count > 0
        cursor.close()
        return exists
    }

    fun getAllBookmarks(): List<VerseItem> {
        val list = mutableListOf<VerseItem>()
        val db = readableDatabase
        val cursor = db.query(
            TABLE_BOOKMARKS,
            null, null, null, null, null, "$COL_ID DESC"
        )
        if (cursor.moveToFirst()) {
            val textIdx = cursor.getColumnIndexOrThrow(COL_TEXT)
            val refIdx = cursor.getColumnIndexOrThrow(COL_REF)
            val transIdx = cursor.getColumnIndexOrThrow(COL_TRANSLATION)
            val dateIdx = cursor.getColumnIndexOrThrow(COL_DATE)
            do {
                list.add(
                    VerseItem(
                        text = cursor.getString(textIdx),
                        reference = cursor.getString(refIdx),
                        translation = cursor.getString(transIdx),
                        dateFetched = cursor.getString(dateIdx),
                        isBookmarked = true
                    )
                )
            } while (cursor.moveToNext())
        }
        cursor.close()
        return list
    }
}
