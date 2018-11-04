package com.appapply.igflexin.ui.auth

import androidx.lifecycle.ViewModel
import com.appapply.igflexin.model.User
import com.appapply.igflexin.repository.UserRepository

class AuthViewModel(private val userRepository: UserRepository) : ViewModel() {
    val userLiveData = userRepository.userLiveData

    fun changeUser() {
        userRepository.changeUser(User("test1", "test@test.test", "Test", false))
    }
}
