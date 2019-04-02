package com.appapply.igflexin.ui.app.subscriptionmanagement.subscriptiontab

import android.app.Activity
import androidx.lifecycle.ViewModel;
import com.appapply.igflexin.repository.SubscriptionRepository

class SubscriptionTabViewModel(private val subscriptionRepository: SubscriptionRepository) : ViewModel() {
    val subscriptionBundlesLiveData = subscriptionRepository.subscriptionBundlesLiveData
    val subscriptionLiveData = subscriptionRepository.subscriptionLiveData

    fun upgradeDowngradeSubscription(activity: Activity, oldID: String, ID: String) {
        subscriptionRepository.upgradeDowngradeSubscription(activity, oldID, ID)
    }
}