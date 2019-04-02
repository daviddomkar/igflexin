package com.appapply.igflexin.ui.auth.verifyemail

import androidx.lifecycle.ViewModel
import com.appapply.igflexin.repository.AuthRepository

class VerifyEmailViewModel(private val authRepository: AuthRepository) : ViewModel() {
    val emailSentStatusLiveData = authRepository.emailSentStatusLiveData

    var activationEmailSent = false

    init {
        activationEmailSent = true
        authRepository.sendVerificationEmail()
    }

    fun sendVerificationEmail() {
        authRepository.sendVerificationEmail()
    }

    fun signOut() {
        authRepository.signOut()
    }
}
