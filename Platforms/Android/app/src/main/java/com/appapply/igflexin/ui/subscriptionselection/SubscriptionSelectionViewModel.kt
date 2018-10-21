package com.appapply.igflexin.ui.subscriptionselection

import androidx.lifecycle.LiveData
import androidx.lifecycle.ViewModel
import com.appapply.igflexin.livedata.billing.BillingManagerStatusLiveData
import com.appapply.igflexin.pojo.Subscription
import com.appapply.igflexin.repositories.SubscriptionRepository

class SubscriptionSelectionViewModel(private val subscriptionRepository: SubscriptionRepository) : ViewModel() {
    fun getSubscriptionDetailsLiveData(subscriptionIDs: List<String>): LiveData<List<Subscription>> {
        return subscriptionRepository.getSubscriptionDetailsLiveData(subscriptionIDs)
    }

    fun getSubscriptionStatusLiveData(): BillingManagerStatusLiveData {
        return subscriptionRepository.getSubscriptionStatusLiveData()
    }
}
