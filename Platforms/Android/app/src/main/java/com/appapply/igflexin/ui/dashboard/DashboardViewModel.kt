package com.appapply.igflexin.ui.dashboard

import androidx.lifecycle.LiveData
import androidx.lifecycle.ViewModel
import com.appapply.igflexin.pojo.User
import com.appapply.igflexin.repositories.AuthRepository
import com.appapply.igflexin.repositories.UserRepository

class DashboardViewModel(private val authRepository: AuthRepository, private val userRepository: UserRepository) : ViewModel() {

    fun signOut() {
        authRepository.signOut()
    }

    fun getSignedInLiveData() : LiveData<Boolean> {
        return authRepository.getSignedInLiveData()
    }

    fun getUserLiveData() : LiveData<User> {
        return userRepository.getUserLiveData()
    }
}
