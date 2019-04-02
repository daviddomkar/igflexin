package com.appapply.igflexin.ui.auth.login

import androidx.lifecycle.ViewModel
import com.appapply.igflexin.repository.AuthRepository

class LogInViewModel(private val authRepository: AuthRepository) : ViewModel() {
    fun signIn(email: String, password: String) {
        authRepository.signIn(email, password)
    }
}
