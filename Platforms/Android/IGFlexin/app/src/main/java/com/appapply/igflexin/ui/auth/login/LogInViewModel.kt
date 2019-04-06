package com.appapply.igflexin.ui.auth.login

import androidx.lifecycle.ViewModel
import com.appapply.igflexin.repository.AuthRepository

class LogInViewModel(private val authRepository: AuthRepository) : ViewModel() {

    val passwordResetStatusLiveData = authRepository.passwordResetStatusLiveData

    fun signIn(email: String, password: String) {
        authRepository.signIn(email, password)
    }

    fun resetPassword(email: String) {
        authRepository.resetPassword(email)
    }
}
