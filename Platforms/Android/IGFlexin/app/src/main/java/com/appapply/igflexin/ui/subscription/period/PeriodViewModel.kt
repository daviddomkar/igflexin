package com.appapply.igflexin.ui.subscription.period

import androidx.lifecycle.ViewModel
import com.appapply.igflexin.repository.SubscriptionRepository

class PeriodViewModel(private val subscriptionRepository: SubscriptionRepository) : ViewModel() {
    val subscriptionPeriodsLiveData = subscriptionRepository.subscriptionPeriodsLiveData

    init {
        subscriptionRepository.getSubscriptionPeriods()
    }

    fun getSubscriptionPeriods() {
        subscriptionRepository.getSubscriptionPeriods()
    }

}
