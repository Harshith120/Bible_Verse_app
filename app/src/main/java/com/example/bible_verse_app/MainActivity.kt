package com.example.bible_verse_app

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.os.Bundle
import android.widget.ImageButton
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.google.android.material.button.MaterialButton

class MainActivity : AppCompatActivity() {

    private val verses = listOf(
        Pair("For God so loved the world, that he gave his one and only Son, that whoever believes in him should not perish, but have eternal life.", "John 3:16"),
        Pair("I can do all things through Christ who strengthens me.", "Philippians 4:13"),
        Pair("The LORD is my shepherd; I shall not want.", "Psalm 23:1"),
        Pair("For I know the plans I have for you, says the LORD, plans for peace and not for evil, to give you hope and a future.", "Jeremiah 29:11"),
        Pair("Trust in the LORD with all your heart, and do not lean on your own understanding.", "Proverbs 3:5"),
        Pair("Be still, and know that I am God.", "Psalm 46:10")
    )

    private var currentVerseIndex = 0
    private var isBookmarked = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val tvVerseText = findViewById<TextView>(R.id.tvVerseText)
        val tvVerseReference = findViewById<TextView>(R.id.tvVerseReference)
        val btnBookmark = findViewById<ImageButton>(R.id.btnBookmark)
        val btnCopy = findViewById<ImageButton>(R.id.btnCopy)
        val btnRefresh = findViewById<MaterialButton>(R.id.btnRefresh)

        fun updateUI() {
            val (text, ref) = verses[currentVerseIndex]
            tvVerseText.text = "\"$text\""
            tvVerseReference.text = ref
            btnBookmark.setImageResource(
                if (isBookmarked) android.R.drawable.btn_star_big_on
                else android.R.drawable.btn_star_big_off
            )
        }

        updateUI()

        btnBookmark.setOnClickListener {
            isBookmarked = !isBookmarked
            btnBookmark.setImageResource(
                if (isBookmarked) android.R.drawable.btn_star_big_on
                else android.R.drawable.btn_star_big_off
            )
            val msg = if (isBookmarked) "Verse bookmarked!" else "Bookmark removed"
            Toast.makeText(this, msg, Toast.LENGTH_SHORT).show()
        }

        btnCopy.setOnClickListener {
            val (text, ref) = verses[currentVerseIndex]
            val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
            val clip = ClipData.newPlainText("Bible Verse", "\"$text\" - $ref")
            clipboard.setPrimaryClip(clip)
            Toast.makeText(this, "Verse copied to clipboard!", Toast.LENGTH_SHORT).show()
        }

        btnRefresh.setOnClickListener {
            currentVerseIndex = (currentVerseIndex + 1) % verses.size
            isBookmarked = false
            updateUI()
            Toast.makeText(this, "Refreshed verse!", Toast.LENGTH_SHORT).show()
        }
    }
}
