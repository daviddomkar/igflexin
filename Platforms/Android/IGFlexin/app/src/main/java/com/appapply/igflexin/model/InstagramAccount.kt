package com.appapply.igflexin.model

data class InstagramAccount(val username: String, val encryptedPassword: String, val userID: String) {
    constructor() : this("", "", "")
}