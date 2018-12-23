package com.appapply.igflexin.ui.app.subscriptionmanagement

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel;
import com.appapply.igflexin.billing.Product
import com.appapply.igflexin.repository.InstagramRepository
import com.appapply.igflexin.repository.SubscriptionRepository

class SubscriptionManagementViewModel(private val subscriptionRepository: SubscriptionRepository, instagramRepository: InstagramRepository) : ViewModel() {
    private val showErrorLayoutMutableLiveData: MutableLiveData<Boolean> = MutableLiveData()

    val showErrorLayoutLiveData: LiveData<Boolean> = showErrorLayoutMutableLiveData
    val subscriptionBundlesLiveData = subscriptionRepository.subscriptionBundlesLiveData
    val subscriptionUpgradeDowngradeLiveData = subscriptionRepository.subscriptionUpgradeDowngradeLiveData
    val subscriptionPurchaseResultLiveData = subscriptionRepository.subscriptionPurchaseResultLiveData
    val subscriptionVerifiedLiveData = subscriptionRepository.subscriptionVerifiedLiveData
    val subscriptionLiveData = subscriptionRepository.subscriptionLiveData
    val addInstagramAccountStatusLiveData = instagramRepository.addInstagramAccountStatusLiveData

    // var error = false
    // var errorMessage: Int = 0

    var lastSubscription = "none"

    init {
        getSubscriptionBundles()
    }

    fun showErrorLayout(show: Boolean) {
        showErrorLayoutMutableLiveData.value = show
    }

    fun resetPurchaseLiveData() {
        subscriptionRepository.resetPurchaseLiveData()
    }

    fun verifySubscription(id: String, token: String) {
        subscriptionRepository.verifySubscription(id, token)
    }

    fun getSubscriptionBundles() {
        subscriptionRepository.getSubscriptionBundles(listOf(
            Product.WEEKLY_BASIC_SUBSCRIPTION,
            Product.WEEKLY_STANDARD_SUBSCRIPTION,
            Product.WEEKLY_BUSINESS_SUBSCRIPTION,
            Product.WEEKLY_BUSINESS_PRO_SUBSCRIPTION,
            Product.MONTHLY_BASIC_SUBSCRIPTION,
            Product.MONTHLY_STANDARD_SUBSCRIPTION,
            Product.MONTHLY_BUSINESS_SUBSCRIPTION,
            Product.MONTHLY_BUSINESS_PRO_SUBSCRIPTION,
            Product.QUARTERLY_BASIC_SUBSCRIPTION,
            Product.QUARTERLY_STANDARD_SUBSCRIPTION,
            Product.QUARTERLY_BUSINESS_SUBSCRIPTION,
            Product.QUARTERLY_BUSINESS_PRO_SUBSCRIPTION
        ))
    }

    override fun onCleared() {
        super.onCleared()
        resetPurchaseLiveData()
    }
}
