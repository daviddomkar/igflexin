package com.appapply.igflexin.ui.app

import androidx.lifecycle.ViewModel
import com.appapply.igflexin.repository.AuthRepository
import com.appapply.igflexin.repository.SubscriptionRepository
import com.appapply.igflexin.repository.UserRepository

class AppViewModel(private val authRepository: AuthRepository, private val userRepository: UserRepository, private val subscriptionRepository: SubscriptionRepository) : ViewModel() {
    val subscriptionLiveData = subscriptionRepository.subscriptionLiveData
    val userLiveData = userRepository.userLiveData

    fun signOut() {
        authRepository.signOut()
    }
}
