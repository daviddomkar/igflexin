package com.appapply.igflexin.ui.auth

import android.content.Intent
import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.appapply.igflexin.events.Event
import com.appapply.igflexin.repository.AuthRepository
import com.appapply.igflexin.repository.GoogleSignInRepository
import com.appapply.igflexin.repository.UserRepository

class AuthViewModel(private val authRepository: AuthRepository, private val userRepository: UserRepository, private val googleSignInRepository: GoogleSignInRepository) : ViewModel() {
    private val showProgressBarMutableLiveData: MutableLiveData<Pair<Boolean, Boolean>> = MutableLiveData()
    private val snackMutableLiveData: MutableLiveData<Event<String>> = MutableLiveData()

    var loading = false
        private set

    var displayLogin = false

    val authErrorLiveData = authRepository.authErrorLiveData
    val userLiveData = userRepository.userLiveData
    val showProgressBarLiveData: LiveData<Pair<Boolean, Boolean>> = showProgressBarMutableLiveData
    val snackLiveData: LiveData<Event<String>> = snackMutableLiveData

    fun showProgressBar(show: Boolean, explicit: Boolean = false) {
        showProgressBarMutableLiveData.value = Pair(show, explicit)
        loading = show
    }

    fun getGoogleSignInIntent(): Intent {
        return googleSignInRepository.getGoogleSignInIntent()
    }

    fun snack(message: String) {
        snackMutableLiveData.value = Event(message)
    }
}
