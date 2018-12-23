package com.appapply.igflexin.repository

import androidx.lifecycle.LiveData
import com.appapply.igflexin.livedata.firebase.FirebaseConnectionLiveData

interface ConnectionRepository {
    val connectionLiveData: LiveData<Boolean>
}

class FirebaseConnectionRepository(private val firebaseConnectionLiveData: FirebaseConnectionLiveData) : ConnectionRepository {
    override val connectionLiveData: LiveData<Boolean>
        get() = firebaseConnectionLiveData
}