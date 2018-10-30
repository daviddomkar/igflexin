package com.appapply.igflexin.pojo

import com.appapply.igflexin.codes.StatusCode

class Resource<T>(val status: StatusCode, val data: T?) {

    /*
    fun <T> success(data: T): Resource<T> {
        return Resource(StatusCode.SUCCESS, data)
    }

    fun <T> pending(data: T): Resource<T> {
        return Resource(StatusCode.PENDING, data)
    }

    fun <T> error(data: T, status: StatusCode = StatusCode.ERROR): Resource<T> {
        return Resource(status, data)
    }*/
}