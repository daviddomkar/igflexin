package com.appapply.igflexin.model

data class InstagramAccount(val username: String, val encryptedPassword: String, val userID: String, val status: String?, val serviceID: String?) {
    constructor() : this("", "", "", null, null)
}