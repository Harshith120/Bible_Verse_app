package com.example.bible_verse_app

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.example.bible_verse_app.auth.FirebaseAuthManager
import com.google.android.material.textfield.TextInputEditText

class RegisterActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_register)

        val etEmail = findViewById<TextInputEditText>(R.id.etRegEmail)
        val etPassword = findViewById<TextInputEditText>(R.id.etRegPassword)
        val etConfirmPassword = findViewById<TextInputEditText>(R.id.etRegConfirmPassword)
        val btnSubmit = findViewById<Button>(R.id.btnRegisterSubmit)

        btnSubmit.setOnClickListener {
            val email = etEmail.text?.toString()?.trim().orEmpty()
            val pass = etPassword.text?.toString()?.trim().orEmpty()
            val confirmPass = etConfirmPassword.text?.toString()?.trim().orEmpty()

            if (email.isEmpty()) {
                etEmail.error = "Please enter your email"
                return@setOnClickListener
            }
            if (pass.length < 6) {
                etPassword.error = "Password must be at least 6 characters"
                return@setOnClickListener
            }
            if (pass != confirmPass) {
                etConfirmPassword.error = "Passwords do not match"
                return@setOnClickListener
            }

            FirebaseAuthManager.signUp(
                email = email,
                pass = pass,
                onSuccess = { registeredEmail ->
                    Toast.makeText(this, "Account created! Welcome, $registeredEmail", Toast.LENGTH_SHORT).show()
                    val intent = Intent(this, MainActivity::class.java)
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                    startActivity(intent)
                    finish()
                },
                onFailure = { errorMsg ->
                    Toast.makeText(this, errorMsg, Toast.LENGTH_LONG).show()
                }
            )
        }
    }
}
