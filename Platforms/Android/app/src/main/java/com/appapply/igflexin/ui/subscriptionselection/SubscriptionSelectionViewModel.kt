package com.appapply.igflexin.ui.subscriptionselection

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.Transformations
import androidx.lifecycle.ViewModel
import com.appapply.igflexin.livedata.billing.BillingManagerStatusLiveData
import com.appapply.igflexin.pojo.Subscription
import com.appapply.igflexin.repositories.SubscriptionRepository

class SubscriptionSelectionViewModel(private val subscriptionRepository: SubscriptionRepository) : ViewModel() {
    private val subscriptionStatusLiveData = subscriptionRepository.getSubscriptionStatusLiveData()

    private val subscriptionDetailsLiveDataInput = MutableLiveData<List<String>>()
    private val subscriptionDetailsLiveData = Transformations.switchMap(subscriptionDetailsLiveDataInput) {
        return@switchMap subscriptionRepository.getSubscriptionDetailsLiveData(it)
    }

    fun setSubscriptionDetailsLiveDataInput(subscriptionIDs: List<String>) {
        subscriptionDetailsLiveDataInput.value = subscriptionIDs
    }

    fun getSubscriptionDetailsLiveData(): LiveData<List<Subscription>> {
        return subscriptionDetailsLiveData
    }

    fun getSubscriptionStatusLiveData(): BillingManagerStatusLiveData {
        return subscriptionStatusLiveData
    }
}
