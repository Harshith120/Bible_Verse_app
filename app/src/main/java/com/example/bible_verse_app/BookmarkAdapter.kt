package com.example.bible_verse_app

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageButton
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.example.bible_verse_app.db.VerseItem

class BookmarkAdapter(
    private var bookmarks: MutableList<VerseItem>,
    private val onDeleteClick: (VerseItem) -> Unit
) : RecyclerView.Adapter<BookmarkAdapter.BookmarkViewHolder>() {

    class BookmarkViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        val tvRef: TextView = itemView.findViewById(R.id.tvItemRef)
        val tvText: TextView = itemView.findViewById(R.id.tvItemText)
        val btnDelete: ImageButton = itemView.findViewById(R.id.btnDeleteBookmark)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BookmarkViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_bookmark, parent, false)
        return BookmarkViewHolder(view)
    }

    override fun onBindViewHolder(holder: BookmarkViewHolder, position: Int) {
        val item = bookmarks[position]
        holder.tvRef.text = "${item.reference} (${item.translation})"
        holder.tvText.text = "\"${item.text}\""
        holder.btnDelete.setOnClickListener {
            onDeleteClick(item)
        }
    }

    override fun getItemCount(): Int = bookmarks.size

    fun updateList(newList: List<VerseItem>) {
        bookmarks.clear()
        bookmarks.addAll(newList)
        notifyDataSetChanged()
    }
}
