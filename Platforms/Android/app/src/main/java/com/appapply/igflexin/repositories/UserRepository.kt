package com.appapply.igflexin.repositories

import com.google.firebase.auth.FirebaseAuth

interface UserRepository {
    fun isUserLoggedIn(): Boolean
}

class FirebaseUserRepository(val firebaseAuth: FirebaseAuth): UserRepository {
    override fun isUserLoggedIn() = false
}