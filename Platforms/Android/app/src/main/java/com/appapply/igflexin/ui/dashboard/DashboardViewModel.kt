package com.appapply.igflexin.ui.dashboard

import androidx.lifecycle.LiveData
import androidx.lifecycle.Transformations
import androidx.lifecycle.ViewModel
import com.appapply.igflexin.pojo.User
import com.appapply.igflexin.repositories.AuthRepository
import com.appapply.igflexin.repositories.UserRepository

class DashboardViewModel(private val authRepository: AuthRepository, private val userRepository: UserRepository) : ViewModel() {
    private val signedInLiveData = Transformations.map(userRepository.getUserLiveData()) { user -> user.uid != null}

    fun signOut() {
        authRepository.signOut()
    }

    fun getSignedInLiveData() : LiveData<Boolean> {
        return signedInLiveData
    }

    fun getUserLiveData() : LiveData<User> {
        return userRepository.getUserLiveData()
    }
}
