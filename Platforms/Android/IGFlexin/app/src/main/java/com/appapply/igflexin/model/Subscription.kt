package com.appapply.igflexin.model

data class Subscription(val uid: String, val orderID: String?, val purchaseToken: String, val subscriptionID: String, val userID: String, val verified: Boolean, val isFromCache: Boolean)