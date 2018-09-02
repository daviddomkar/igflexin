package com.appapply.igflexin.repositories

interface UserRepository {
    fun isUserLoggedIn(): Boolean
}

class FirebaseUserRepository(): UserRepository {
    override fun isUserLoggedIn() = false
}