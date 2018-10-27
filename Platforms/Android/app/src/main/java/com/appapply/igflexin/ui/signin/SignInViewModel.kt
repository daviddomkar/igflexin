package com.appapply.igflexin.ui.signin

import androidx.lifecycle.LiveData
import androidx.lifecycle.ViewModel
import com.appapply.igflexin.codes.StatusCode
import com.appapply.igflexin.events.Event
import com.appapply.igflexin.pojo.User
import com.appapply.igflexin.repositories.AuthRepository
import com.appapply.igflexin.repositories.UserRepository

class SignInViewModel(private val authRepository: AuthRepository, private val userRepository: UserRepository) : ViewModel() {
    fun signIn(email: String, password: String) {
        authRepository.signIn(email, password)
    }

    fun getAuthStatusLiveData(): LiveData<Event<StatusCode>> {
        return authRepository.getAuthStatusLiveData()
    }

    fun getUserLiveData(): LiveData<User> {
        return userRepository.getUserLiveData()
    }
}
