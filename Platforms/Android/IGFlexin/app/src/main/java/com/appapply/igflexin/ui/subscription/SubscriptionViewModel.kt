package com.appapply.igflexin.ui.subscription

import androidx.lifecycle.ViewModel
import com.appapply.igflexin.repository.SubscriptionRepository

class SubscriptionViewModel(private val subscriptionRepository: SubscriptionRepository) : ViewModel() {
    val subscriptionLiveData = subscriptionRepository.subscriptionLiveData
}
