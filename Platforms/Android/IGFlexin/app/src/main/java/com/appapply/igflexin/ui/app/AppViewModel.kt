package com.appapply.igflexin.ui.app

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.appapply.igflexin.repository.AuthRepository
import com.appapply.igflexin.repository.ConnectionRepository
import com.appapply.igflexin.repository.SubscriptionRepository
import com.appapply.igflexin.repository.UserRepository

class AppViewModel(private val authRepository: AuthRepository, private val userRepository: UserRepository, private val subscriptionRepository: SubscriptionRepository, private val connectionRepository: ConnectionRepository) : ViewModel() {
    private val showProgressBarMutableLiveData: MutableLiveData<Pair<Boolean, Boolean>> = MutableLiveData()

    val subscriptionLiveData = subscriptionRepository.subscriptionLiveData
    val userLiveData = userRepository.userLiveData
    val showProgressBarLiveData: LiveData<Pair<Boolean, Boolean>> = showProgressBarMutableLiveData
    val connectionLiveData = connectionRepository.connectionLiveData

    var loading = false
        private set

    fun showProgressBar(show: Boolean, explicit: Boolean = false) {
        showProgressBarMutableLiveData.value = Pair(show, explicit)
        loading = show
    }

    fun signOut() {
        authRepository.signOut()
    }
}
