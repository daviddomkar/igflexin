package com.appapply.igflexin.livedata.firebase

import androidx.lifecycle.LiveData
import com.google.firebase.auth.FirebaseAuth
import org.koin.standalone.KoinComponent
import org.koin.standalone.inject

class FirebaseAuthStateLiveData : LiveData<FirebaseAuth>(), KoinComponent {
    private val firebaseAuth: FirebaseAuth by inject()

    private val listener = FirebaseAuth.AuthStateListener {
        postValue(it)
    }.also {
        firebaseAuth.addAuthStateListener(it)
    }

    /*
    override fun onActive() {
        super.onActive()
    }

    override fun onInactive() {
        super.onInactive()
        firebaseAuth.removeAuthStateListener(listener)
    }*/
}