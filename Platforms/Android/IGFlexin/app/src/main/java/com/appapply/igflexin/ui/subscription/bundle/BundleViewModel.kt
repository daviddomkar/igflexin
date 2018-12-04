package com.appapply.igflexin.ui.subscription.bundle

import android.app.Activity
import androidx.lifecycle.ViewModel
import com.appapply.igflexin.billing.Product
import com.appapply.igflexin.repository.SubscriptionRepository

class BundleViewModel(private val subscriptionRepository: SubscriptionRepository) : ViewModel() {
    val subscriptionBundlesLiveData = subscriptionRepository.subscriptionBundlesLiveData

    private var period = "none"

    fun setPeriod(period: String) {
        if (period != this.period) {
            this.period = period
            getSubscriptionBundles()
        }
    }

    fun purchaseSubscription(activity: Activity, ID: String) {
        subscriptionRepository.purchaseSubscription(activity, ID)
    }

    fun getSubscriptionBundles() {
        when (period) {
            Product.WEEKLY_BASIC_SUBSCRIPTION -> {
                subscriptionRepository.getSubscriptionBundles(listOf(
                    Product.WEEKLY_BASIC_SUBSCRIPTION,
                    Product.WEEKLY_STANDARD_SUBSCRIPTION,
                    Product.WEEKLY_BUSINESS_SUBSCRIPTION,
                    Product.WEEKLY_BUSINESS_PRO_SUBSCRIPTION
                ))
            }
            Product.MONTHLY_BASIC_SUBSCRIPTION -> {
                subscriptionRepository.getSubscriptionBundles(listOf(
                    Product.MONTHLY_BASIC_SUBSCRIPTION,
                    Product.MONTHLY_STANDARD_SUBSCRIPTION,
                    Product.MONTHLY_BUSINESS_SUBSCRIPTION,
                    Product.MONTHLY_BUSINESS_PRO_SUBSCRIPTION
                ))
            }
            Product.QUARTERLY_BASIC_SUBSCRIPTION -> {
                subscriptionRepository.getSubscriptionBundles(listOf(
                    Product.QUARTERLY_BASIC_SUBSCRIPTION,
                    Product.QUARTERLY_STANDARD_SUBSCRIPTION,
                    Product.QUARTERLY_BUSINESS_SUBSCRIPTION,
                    Product.QUARTERLY_BUSINESS_PRO_SUBSCRIPTION
                ))
            }
        }
    }
}
