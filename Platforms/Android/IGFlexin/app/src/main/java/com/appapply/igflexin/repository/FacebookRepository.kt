package com.appapply.igflexin.repository

import android.app.Activity
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.appapply.igflexin.common.OnActivityResultObject
import com.appapply.igflexin.common.Resource
import com.appapply.igflexin.common.StatusCode
import com.appapply.igflexin.events.Event
import com.facebook.CallbackManager
import com.facebook.FacebookCallback
import com.facebook.FacebookException
import com.facebook.login.LoginManager
import com.facebook.login.LoginResult
import com.google.firebase.auth.AuthCredential
import com.google.firebase.auth.FacebookAuthProvider

interface FacebookRepository {
    val authCredentialLiveData: LiveData<Event<Resource<AuthCredential>>>

    fun load()
    fun unload()

    fun onActivityResult(onActivityResultObject: OnActivityResultObject)

    fun signIn(activity: Activity)
}

class FacebookRepositoryImpl(private val loginManager: LoginManager, private val callbackManager: CallbackManager) : FacebookRepository {
    private val permissions = listOf("email", "public_profile")

    private val authCredentialMutableLiveData: MutableLiveData<Event<Resource<AuthCredential>>> = MutableLiveData()

    override val authCredentialLiveData: LiveData<Event<Resource<AuthCredential>>>
        get() = authCredentialMutableLiveData

    override fun load() {
        loginManager.registerCallback(callbackManager, object : FacebookCallback<LoginResult> {
            override fun onSuccess(loginResult: LoginResult) {
                authCredentialMutableLiveData.value= Event(Resource(StatusCode.SUCCESS, FacebookAuthProvider.getCredential(loginResult.accessToken.token)))
            }

            override fun onCancel() {
                authCredentialMutableLiveData.value = Event(Resource<AuthCredential>(StatusCode.CANCELED, null))
            }

            override fun onError(exception: FacebookException) {

                exception.message?.let {
                    if(it.contains("CONNECTION_FAILURE")) {
                        authCredentialMutableLiveData.value = Event(Resource<AuthCredential>(StatusCode.NETWORK_ERROR, null))
                        return
                    }
                }

                authCredentialMutableLiveData.value = Event(Resource<AuthCredential>(StatusCode.ERROR, null))
            }
        })
    }

    override fun unload() {
        loginManager.unregisterCallback(callbackManager)
    }

    override fun onActivityResult(onActivityResultObject: OnActivityResultObject) {
        callbackManager.onActivityResult(onActivityResultObject.requestCode, onActivityResultObject.resultCode, onActivityResultObject.data)
    }

    override fun signIn(activity: Activity) {
        loginManager.logInWithReadPermissions(activity, permissions)
    }
}