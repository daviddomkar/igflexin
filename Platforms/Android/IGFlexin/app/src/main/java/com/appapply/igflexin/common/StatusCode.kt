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