package com.appapply.igflexin.ui.subscriptionselectiondetail

import android.app.Activity
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.Transformations
import androidx.lifecycle.ViewModel
import com.appapply.igflexin.codes.StatusCode
import com.appapply.igflexin.livedata.billing.BillingManagerStatusLiveData
import com.appapply.igflexin.livedata.billing.PurchasesUpdatedLiveData
import com.appapply.igflexin.pojo.Subscription
import com.appapply.igflexin.pojo.User
import com.appapply.igflexin.repositories.SubscriptionRepository
import com.appapply.igflexin.repositories.UserRepository

class SubscriptionSelectionDetailViewModel(private val subscriptionRepository: SubscriptionRepository) : ViewModel() {
    private val subscriptionDetailsLiveDataInput = MutableLiveData<List<String>>()
    private val subscriptionDetailsLiveData = Transformations.switchMap(subscriptionDetailsLiveDataInput) {
        return@switchMap subscriptionRepository.getSubscriptionDetailsLiveData(it)
    }

    private val subscriptionPurchasesLiveData = subscriptionRepository.getSubscriptionPurchasesLiveData()
    private val subscriptionVerifiedLiveData = subscriptionRepository.getSubscriptionVerifiedLiveData()
    private val subscriptionStatusLiveData = subscriptionRepository.getSubscriptionStatusLiveData()

    fun setSubscriptionDetailsLiveDataInput(subscriptionIDs: List<String>) {
        subscriptionDetailsLiveDataInput.value = subscriptionIDs
    }

    fun initiateSubscriptionPurchaseFlow(activity: Activity, id: String) {
        subscriptionRepository.initiateSubscriptionPurchaseFlow(activity, id)
    }

    fun verifySubscriptionPurchase(id: String, token: String) {
        subscriptionRepository.verifyPurchase(id, token)
    }

    fun validateSubscriptions() {
        subscriptionRepository.validateGooglePlaySubscriptions()
    }

    fun getSubscriptionDetailsLiveData(): LiveData<List<Subscription>> {
        return subscriptionDetailsLiveData
    }

    fun getSubscriptionPurchasesLiveData() : PurchasesUpdatedLiveData {
        return subscriptionPurchasesLiveData
    }

    fun getSubscriptionVerifiedLiveData(): LiveData<StatusCode> {
        return subscriptionVerifiedLiveData
    }

    fun getSubscriptionStatusLiveData(): BillingManagerStatusLiveData {
        return subscriptionStatusLiveData
    }
}
