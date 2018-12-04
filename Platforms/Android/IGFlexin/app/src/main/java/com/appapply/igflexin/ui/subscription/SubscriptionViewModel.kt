package com.appapply.igflexin.ui.subscription

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.appapply.igflexin.repository.AuthRepository
import com.appapply.igflexin.repository.SubscriptionRepository

class SubscriptionViewModel(private val authRepository: AuthRepository, private val subscriptionRepository: SubscriptionRepository) : ViewModel() {
    private val showProgressBarMutableLiveData: MutableLiveData<Pair<Boolean, Boolean>> = MutableLiveData()

    val subscriptionLiveData = subscriptionRepository.subscriptionLiveData
    val subscriptionPurchaseLiveData = subscriptionRepository.subscriptionPurchaseLiveData
    val subscriptionPurchaseResultLiveData = subscriptionRepository.subscriptionPurchaseResultLiveData
    val subscriptionVerifiedLiveData = subscriptionRepository.subscriptionVerifiedLiveData

    val showProgressBarLiveData: LiveData<Pair<Boolean, Boolean>> = showProgressBarMutableLiveData

    var loading = false
        private set

    var dialogCanceled = false

    fun resetPurchaseLiveData() {
        dialogCanceled = false
        subscriptionRepository.resetPurchaseLiveData()
    }

    fun logOut() {
        authRepository.signOut()
    }

    fun verifySubscription(id: String, token: String) {
        subscriptionRepository.verifySubscription(id, token)
    }

    fun showProgressBar(show: Boolean, explicit: Boolean = false) {
        showProgressBarMutableLiveData.value = Pair(show, explicit)
        loading = show
    }

    override fun onCleared() {
        super.onCleared()
        resetPurchaseLiveData()
    }
}
