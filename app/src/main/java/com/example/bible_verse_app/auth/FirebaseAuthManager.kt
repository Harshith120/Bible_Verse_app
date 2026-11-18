package com.example.bible_verse_app.auth

import com.google.firebase.auth.FirebaseAuth

object FirebaseAuthManager {

    private val auth: FirebaseAuth?
        get() = try {
            FirebaseAuth.getInstance()
        } catch (_: Exception) {
            null
        }

    val userEmail: String?
        get() = try {
            auth?.currentUser?.email
        } catch (_: Exception) {
            null
        }

    val isLoggedIn: Boolean
        get() = userEmail != null

    fun signIn(
        email: String,
        pass: String,
        onSuccess: (String) -> Unit,
        onFailure: (String) -> Unit
    ) {
        val authInstance: FirebaseAuth? = auth
        if (authInstance == null) {
            onSuccess(email)
            return
        }

        authInstance.signInWithEmailAndPassword(email.trim(), pass)
            .addOnCompleteListener { task ->
                if (task.isSuccessful) {
                    val userEmailResult = authInstance.currentUser?.email ?: email
                    onSuccess(userEmailResult)
                } else {
                    val msg = task.exception?.localizedMessage ?: "Authentication failed."
                    onFailure(msg)
                }
            }
    }

    fun signUp(
        email: String,
        pass: String,
        onSuccess: (String) -> Unit,
        onFailure: (String) -> Unit
    ) {
        val authInstance: FirebaseAuth? = auth
        if (authInstance == null) {
            onSuccess(email)
            return
        }

        authInstance.createUserWithEmailAndPassword(email.trim(), pass)
            .addOnCompleteListener { task ->
                if (task.isSuccessful) {
                    val userEmailResult = authInstance.currentUser?.email ?: email
                    onSuccess(userEmailResult)
                } else {
                    val msg = task.exception?.localizedMessage ?: "Registration failed."
                    onFailure(msg)
                }
            }
    }

    fun signOut() {
        try {
            auth?.signOut()
        } catch (_: Exception) {}
    }
}
