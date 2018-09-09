package com.appapply.igflexin.repositories

import android.app.Activity
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.appapply.igflexin.codes.StatusCode
import com.appapply.igflexin.events.Event
import com.appapply.igflexin.pojo.OnActivityResultCall
import com.facebook.CallbackManager
import com.facebook.login.LoginManager
import com.facebook.FacebookException
import com.facebook.login.LoginResult
import com.facebook.FacebookCallback
import com.google.firebase.auth.AuthCredential
import com.google.firebase.auth.FacebookAuthProvider

interface FacebookRepository {
    fun load()
    fun unload()

    fun aquireActivityResult(onActivityResultCall: OnActivityResultCall)
    fun signIn(activity: Activity)

    fun getCredentialLiveData() : LiveData<Event<AuthCredential>>
    fun getCredentialStatusLiveData() : LiveData<Event<StatusCode>>
}

class FacebookRepositoryImpl(private val loginManager: LoginManager, private val callbackManager: CallbackManager) : FacebookRepository {
    private var credentialStatusLiveData: MutableLiveData<Event<StatusCode>> = MutableLiveData()
    private var credentialLiveData: MutableLiveData<Event<AuthCredential>> = MutableLiveData()

    private val permissions = listOf("email", "public_profile")

    override fun load() {
        loginManager.registerCallback(callbackManager, object : FacebookCallback<LoginResult> {
            override fun onSuccess(loginResult: LoginResult) {
                credentialLiveData.value = Event(FacebookAuthProvider.getCredential(loginResult.accessToken.token))
                credentialStatusLiveData.value = Event(StatusCode.SUCCESS)
            }

            override fun onCancel() {
                credentialStatusLiveData.value = Event(StatusCode.CANCELED)
            }

            override fun onError(exception: FacebookException) {

                exception.message?.let {
                    if(it.contains("CONNECTION_FAILURE")) {
                        credentialStatusLiveData.value = Event(StatusCode.NETWORK_ERROR)
                        return
                    }
                }

                credentialStatusLiveData.value = Event(StatusCode.ERROR)
            }
        })
    }

    override fun aquireActivityResult(onActivityResultCall: OnActivityResultCall) {
        callbackManager.onActivityResult(onActivityResultCall.requestCode, onActivityResultCall.resultCode, onActivityResultCall.data)
    }

    override fun signIn(activity: Activity) {
        loginManager.logInWithReadPermissions(activity, permissions)
    }

    override fun getCredentialStatusLiveData() : LiveData<Event<StatusCode>> {
        return credentialStatusLiveData
    }

    override fun getCredentialLiveData(): LiveData<Event<AuthCredential>> {
        return credentialLiveData
    }

    override fun unload() {
        loginManager.unregisterCallback(callbackManager)
    }
}