package com.appapply.igflexin.common

data class DataOrException<out T, out E: Exception?>(val data: T?, val exception: E?)