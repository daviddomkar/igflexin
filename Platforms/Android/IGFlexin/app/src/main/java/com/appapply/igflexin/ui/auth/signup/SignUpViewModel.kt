package com.appapply.igflexin.ui.auth.signup

import androidx.lifecycle.ViewModel;
import com.appapply.igflexin.repository.AuthRepository

class SignUpViewModel(private val authRepository: AuthRepository) : ViewModel() {

    fun signUp(name: String, email: String, password: String) {
        authRepository.signUp(name, email, password)
    }
}
