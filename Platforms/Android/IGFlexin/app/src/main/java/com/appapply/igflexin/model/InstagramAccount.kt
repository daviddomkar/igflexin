package com.appapply.igflexin.model

data class InstagramAccount(val id: Long, val username: String, val fullName: String, val encryptedPassword: String, val userID: String, val photoURL: String, val status: String) {
    constructor() : this(0, "","", "", "", "", "")
}