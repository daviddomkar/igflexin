package com.appapply.igflexin.ui.app.subscriptionmanagement

import androidx.lifecycle.ViewModel;
import com.appapply.igflexin.billing.Product
import com.appapply.igflexin.repository.SubscriptionRepository

class SubscriptionManagementViewModel(private val subscriptionRepository: SubscriptionRepository) : ViewModel() {
    val subscriptionBundlesLiveData = subscriptionRepository.subscriptionBundlesLiveData

    var error = false
    var errorMessage: Int = 0

    init {
        getSubscriptionBundles()
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
}
