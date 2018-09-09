package com.appapply.igflexin.repositories

import android.content.Intent
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.appapply.igflexin.codes.StatusCode
import com.appapply.igflexin.events.Event
import com.appapply.igflexin.livedata.AbsentLiveData
import com.facebook.login.LoginManager
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.common.api.CommonStatusCodes
import com.google.firebase.auth.AuthCredential
import com.google.firebase.auth.GoogleAuthProvider

interface GoogleSignInRepository {
    fun getSignInIntentLiveData() : LiveData<Event<Intent>>
    fun getCredentialStatusLiveData() : LiveData<Event<StatusCode>>
    fun getCredentialLiveData(data: Intent) : LiveData<Event<AuthCredential>>
}

class GoogleSignInRepositoryImpl(private val googleSignInClient: GoogleSignInClient) : GoogleSignInRepository {
    private var credentialStatusLiveData: MutableLiveData<Event<StatusCode>> = MutableLiveData()

    override fun getSignInIntentLiveData(): LiveData<Event<Intent>> {
        val signInIntentLiveData: MutableLiveData<Event<Intent>> = MutableLiveData()
        signInIntentLiveData.value = Event(googleSignInClient.signInIntent)
        return signInIntentLiveData
    }

    override fun getCredentialStatusLiveData() : LiveData<Event<StatusCode>> {
        return credentialStatusLiveData
    }

    override fun getCredentialLiveData(data: Intent) : LiveData<Event<AuthCredential>> {
        val credentialLiveData: MutableLiveData<Event<AuthCredential>> = MutableLiveData()
        val task = GoogleSignIn.getSignedInAccountFromIntent(data)

        try {
            val account = task.getResult(ApiException::class.java)
            credentialLiveData.value = Event(GoogleAuthProvider.getCredential(account.idToken, null))
            credentialStatusLiveData.value = Event(StatusCode.SUCCESS)
        } catch(e: ApiException) {
            when (e.statusCode) {
                CommonStatusCodes.NETWORK_ERROR -> {
                    credentialStatusLiveData.value = Event(StatusCode.NETWORK_ERROR)
                }
                CommonStatusCodes.CANCELED -> {
                    credentialStatusLiveData.value = Event(StatusCode.CANCELED)
                }
                12501 -> {
                    credentialStatusLiveData.value = Event(StatusCode.CANCELED)
                } else -> {
                    credentialStatusLiveData.value = Event(StatusCode.ERROR)
                }
            }

            return AbsentLiveData.create()
        }

        return credentialLiveData
    }
}