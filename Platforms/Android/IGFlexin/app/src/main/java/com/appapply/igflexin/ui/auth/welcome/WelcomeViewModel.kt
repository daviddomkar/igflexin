package com.appapply.igflexin.ui.auth.welcome

import android.app.Activity
import android.content.Intent
import androidx.lifecycle.LiveData
import androidx.lifecycle.ViewModel;
import com.appapply.igflexin.common.OnActivityResultObject
import com.appapply.igflexin.common.Resource
import com.appapply.igflexin.events.Event
import com.appapply.igflexin.repository.AuthRepository
import com.appapply.igflexin.repository.FacebookRepository
import com.appapply.igflexin.repository.GoogleSignInRepository
import com.google.firebase.auth.AuthCredential

class WelcomeViewModel(private val authRepository: AuthRepository, private val googleSignInRepository: GoogleSignInRepository, private val facebookRepository: FacebookRepository) : ViewModel() {
    val facebookAuthCredentialLiveData: LiveData<Event<Resource<AuthCredential>>> = facebookRepository.authCredentialLiveData

    init {
        facebookRepository.load()
    }

    fun getGoogleAuthCredential(data: Intent) : Resource<AuthCredential> {
        return googleSignInRepository.getGoogleAuthCredential(data)
    }

    fun signInWithCredential(authCredential: AuthCredential) {
        authRepository.signInWithCredential(authCredential)
    }

    fun signInFacebook(activity: Activity) {
        facebookRepository.signIn(activity)
    }

    fun onActivityResult(onActivityResultObject: OnActivityResultObject) {
        facebookRepository.onActivityResult(onActivityResultObject)
    }

    override fun onCleared() {
        facebookRepository.unload()
    }
}
