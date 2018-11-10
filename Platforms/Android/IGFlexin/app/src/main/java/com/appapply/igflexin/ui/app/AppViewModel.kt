package com.appapply.igflexin.ui.app

import androidx.lifecycle.ViewModel
import com.appapply.igflexin.repository.SubscriptionRepository

class AppViewModel(private val subscriptionRepository: SubscriptionRepository) : ViewModel() {
    val subscriptionLiveData = subscriptionRepository.subscriptionLiveData
}
