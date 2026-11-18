package com.example.bible_verse_app

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.example.bible_verse_app.auth.FirebaseAuthManager
import com.google.android.material.textfield.TextInputEditText

class LoginActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // If user is already logged in with Firebase, open MainActivity directly
        if (FirebaseAuthManager.isLoggedIn) {
            openMainActivity()
            return
        }

        setContentView(R.layout.activity_login)

        val etEmail = findViewById<TextInputEditText>(R.id.etEmail)
        val etPassword = findViewById<TextInputEditText>(R.id.etPassword)
        val btnLogin = findViewById<Button>(R.id.btnLogin)
        val tvRegisterLink = findViewById<TextView>(R.id.tvRegisterLink)
        val btnSkip = findViewById<Button>(R.id.btnSkip)

        btnLogin.setOnClickListener {
            val email = etEmail.text?.toString()?.trim().orEmpty()
            val pass = etPassword.text?.toString()?.trim().orEmpty()

            if (email.isEmpty()) {
                etEmail.error = "Please enter your email"
                return@setOnClickListener
            }
            if (pass.isEmpty()) {
                etPassword.error = "Please enter your password"
                return@setOnClickListener
            }

            FirebaseAuthManager.signIn(
                email = email,
                pass = pass,
                onSuccess = { loggedInEmail ->
                    Toast.makeText(this, "Welcome back, $loggedInEmail!", Toast.LENGTH_SHORT).show()
                    openMainActivity()
                },
                onFailure = { errorMsg ->
                    Toast.makeText(this, errorMsg, Toast.LENGTH_LONG).show()
                }
            )
        }

        tvRegisterLink.setOnClickListener {
            startActivity(Intent(this, RegisterActivity::class.java))
        }

        btnSkip.setOnClickListener {
            openMainActivity()
        }
    }

    private fun openMainActivity() {
        startActivity(Intent(this, MainActivity::class.java))
        finish()
    }
}
