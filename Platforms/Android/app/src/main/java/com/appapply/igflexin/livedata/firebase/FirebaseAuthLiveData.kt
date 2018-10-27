package com.appapply.igflexin.livedata.firebase

import android.util.Log.d
import androidx.lifecycle.LiveData

import com.google.firebase.auth.FirebaseAuth

import org.koin.standalone.KoinComponent
import org.koin.standalone.inject

class FirebaseAuthLiveData : LiveData<FirebaseAuth>(), KoinComponent {
    private val firebaseAuth: FirebaseAuth by inject()

    private val listener = FirebaseAuth.AuthStateListener {
        d("IGFlexin", "Changed " + (it.currentUser != null).toString())
        value = it
    }

    override fun onActive() {
        super.onActive()
        firebaseAuth.addAuthStateListener(listener)
    }

    override fun onInactive() {
        super.onInactive()
        firebaseAuth.removeAuthStateListener(listener)
    }
}