package com.appapply.igflexin.ui.app.subscriptionmanagement.subscriptiontab

import androidx.lifecycle.ViewModel;
import com.appapply.igflexin.repository.SubscriptionRepository

class SubscriptionTabViewModel(private val subscriptionRepository: SubscriptionRepository) : ViewModel() {
    val subscriptionBundlesLiveData = subscriptionRepository.subscriptionBundlesLiveData
}
