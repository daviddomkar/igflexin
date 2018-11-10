package com.appapply.igflexin.common

open class StatusCode(private val code: Int) {
    companion object {
        val SUCCESS = StatusCode(0)
        val CANCELED = StatusCode(1)
        val NETWORK_ERROR = StatusCode(3)
        val ERROR = StatusCode(4)
        val PENDING = StatusCode(5)
    }
}

open class AuthStatusCode(private val code: Int) : StatusCode(code) {
    companion object {
        val USER_NOT_FOUND = StatusCode(100)
        val USER_DISABLED = StatusCode(101)
        val EMAIL_ALREADY_IN_USE = StatusCode(102)
        val EXISTS_WITH_DIFFERENT_CREDENTIAL = StatusCode(103)
        val CREDENTIAL_ALREADY_IN_USE = StatusCode(104)
        val INVALID_CREDENTIALS = StatusCode(105)
        val WEAK_PASSWORD = StatusCode(106)
    }
}

open class BillingStatusCode(private val code: Int) : StatusCode(code) {
    companion object {
        val BILLING_UNAVAILABLE = StatusCode(200)
        val FEATURE_NOT_SUPPORTED = StatusCode(201)
        val ITEM_ALREADY_OWNED = StatusCode(202)
        val ITEM_NOT_OWNED = StatusCode(203)
        val ITEM_UNAVAILABLE = StatusCode(204)
        val SERVICE_DISCONNECTED = StatusCode(205)
    }
}