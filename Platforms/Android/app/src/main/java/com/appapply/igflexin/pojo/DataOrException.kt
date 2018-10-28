package com.appapply.igflexin.pojo

data class DataOrException<out T, out E: Exception?>(val data: T?, val exception: E?)