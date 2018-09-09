package com.appapply.igflexin.ui.welcomescreen

import android.app.Activity
import android.content.Intent
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.appapply.igflexin.codes.StatusCode
import com.appapply.igflexin.events.Event
import com.appapply.igflexin.pojo.OnActivityResultCall
import com.appapply.igflexin.repositories.AuthRepository
import com.appapply.igflexin.repositories.FacebookRepository
import com.appapply.igflexin.repositories.GoogleSignInRepository
import com.google.firebase.auth.AuthCredential

class WelcomeScreenViewModel(private val authRepository: AuthRepository, private val googleSignInRepository: GoogleSignInRepository, private val facebookRepository: FacebookRepository) : ViewModel() {
    private val showProgressBarLiveData: MutableLiveData<Boolean> = MutableLiveData()

    fun init() {
        facebookRepository.load()
    }

    fun showProgressBar(show: Boolean) {
        showProgressBarLiveData.value = show
    }

    fun aquireActivityResult(onActivityResultCall: OnActivityResultCall) {
        facebookRepository.aquireActivityResult(onActivityResultCall)
    }

    fun getShowProgressBarLiveData(): LiveData<Boolean> {
        return showProgressBarLiveData
    }

    fun getAuthStatusLiveData(): LiveData<Event<StatusCode>> {
        return authRepository.getAuthStatusLiveData()
    }

    fun getGoogleSignInSignInIntentLiveData(): LiveData<Event<Intent>> {
        return googleSignInRepository.getSignInIntentLiveData()
    }

    fun getGoogleCredentialStatusLiveData(): LiveData<Event<StatusCode>> {
        return googleSignInRepository.getCredentialStatusLiveData()
    }

    fun getGoogleCredentialLiveData(data: Intent): LiveData<Event<AuthCredential>> {
        return googleSignInRepository.getCredentialLiveData(data)
    }

    fun getFacebookCredentialStatusLiveData(): LiveData<Event<StatusCode>> {
        return facebookRepository.getCredentialStatusLiveData()
    }

    fun getFacebookCredentialLiveData(): LiveData<Event<AuthCredential>> {
        return facebookRepository.getCredentialLiveData()
    }

    fun applyCredential(credential: AuthCredential) {
        authRepository.signInWithCredential(credential)
    }

    fun continueWithFacebook(activity: Activity) {
        facebookRepository.signIn(activity)
    }

    override fun onCleared() {
        facebookRepository.unload()
        super.onCleared()
    }
}
