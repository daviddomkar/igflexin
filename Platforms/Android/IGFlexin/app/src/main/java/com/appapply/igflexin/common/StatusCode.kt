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

open class InstagramStatusCode(private val code: Int) : StatusCode(code) {
    companion object {
        val BAD_PASSWORD = StatusCode(300)
        val ACCOUNT_DOES_NOT_MEET_REQUIREMENTS = StatusCode(301)
        val ACCOUNT_ALREADY_ADDED = StatusCode(302)
        val RESTRICTED_BY_SUBSCRIPTION_PLAN = StatusCode(303)
        val ID_NOT_MATCHING = StatusCode(304)
        val ERROR = StatusCode(305)
        val DATA_EMPTY = StatusCode(306)
        val ACCOUNT_INCOMPLETE = StatusCode(307)
    }
}

fun getStringStatusCode(code: StatusCode): String {
    return when (code) {
        StatusCode.SUCCESS                                      -> "StatusCode.SUCCESS"
        StatusCode.CANCELED                                     -> "StatusCode.CANCELED"
        StatusCode.NETWORK_ERROR                                -> "StatusCode.NETWORK_ERROR"
        StatusCode.ERROR                                        -> "StatusCode.ERROR"
        StatusCode.PENDING                                      -> "StatusCode.PENDING"
        AuthStatusCode.USER_NOT_FOUND                           -> "AuthStatusCode.USER_NOT_FOUND"
        AuthStatusCode.USER_DISABLED                            -> "AuthStatusCode.USER_DISABLED"
        AuthStatusCode.EMAIL_ALREADY_IN_USE                     -> "AuthStatusCode.EMAIL_ALREADY_IN_USE"
        AuthStatusCode.EXISTS_WITH_DIFFERENT_CREDENTIAL         -> "AuthStatusCode.EXISTS_WITH_DIFFERENT_CREDENTIAL"
        AuthStatusCode.CREDENTIAL_ALREADY_IN_USE                -> "AuthStatusCode.CREDENTIAL_ALREADY_IN_USE"
        AuthStatusCode.INVALID_CREDENTIALS                      -> "AuthStatusCode.INVALID_CREDENTIALS"
        AuthStatusCode.WEAK_PASSWORD                            -> "AuthStatusCode.WEAK_PASSWORD"
        BillingStatusCode.BILLING_UNAVAILABLE                   -> "BillingStatusCode.BILLING_UNAVAILABLE"
        BillingStatusCode.FEATURE_NOT_SUPPORTED                 -> "BillingStatusCode.FEATURE_NOT_SUPPORTED"
        BillingStatusCode.ITEM_ALREADY_OWNED                    -> "BillingStatusCode.ITEM_ALREADY_OWNED"
        BillingStatusCode.ITEM_NOT_OWNED                        -> "BillingStatusCode.ITEM_NOT_OWNED"
        BillingStatusCode.ITEM_UNAVAILABLE                      -> "BillingStatusCode.ITEM_UNAVAILABLE"
        BillingStatusCode.SERVICE_DISCONNECTED                  -> "BillingStatusCode.SERVICE_DISCONNECTED"
        InstagramStatusCode.BAD_PASSWORD                        -> "InstagramStatusCode.BAD_PASSWORD"
        InstagramStatusCode.ACCOUNT_DOES_NOT_MEET_REQUIREMENTS  -> "InstagramStatusCode.ACCOUNT_DOES_NOT_MEET_REQUIREMENTS"
        InstagramStatusCode.ACCOUNT_ALREADY_ADDED               -> "InstagramStatusCode.ACCOUNT_ALREADY_ADDED"
        InstagramStatusCode.RESTRICTED_BY_SUBSCRIPTION_PLAN     -> "InstagramStatusCode.RESTRICTED_BY_SUBSCRIPTION_PLAN"
        InstagramStatusCode.ID_NOT_MATCHING                     -> "InstagramStatusCode.ID_NOT_MATCHING"
        InstagramStatusCode.ERROR                               -> "InstagramStatusCode.ERROR"
        InstagramStatusCode.DATA_EMPTY                          -> "InstagramStatusCode.DATA_EMPTY"
        InstagramStatusCode.ACCOUNT_INCOMPLETE                  -> "InstagramStatusCode.ACCOUNT_INCOMPLETE"
        else                                                    -> "StatusCode.UNKNOWN"
    }
}