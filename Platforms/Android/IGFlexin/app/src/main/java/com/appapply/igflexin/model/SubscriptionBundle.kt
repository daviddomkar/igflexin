package com.appapply.igflexin.model

data class SubscriptionBundle(val id: String, val title: String, val price: String, val description: String, val restriction: String)
data class RawSubscriptionBundle(val id: String, val title: Int, val price: String, val description: Int, val restriction: Int)