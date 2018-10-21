package com.appapply.igflexin.repositories

import android.app.Activity
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.android.billingclient.api.BillingClient
import com.appapply.igflexin.billing.BillingManager
import com.appapply.igflexin.billing.PurchaseVerifier
import com.appapply.igflexin.livedata.billing.BillingManagerStatusLiveData
import com.appapply.igflexin.livedata.billing.PurchasesUpdatedLiveData
import com.appapply.igflexin.pojo.Subscription

interface SubscriptionRepository {
    fun initiateSubscriptionPurchaseFlow(activity: Activity, subscriptionID: String)
    fun verifyPurchase(userID: String, id: String, token: String)

    fun getSubscriptionStatusLiveData() : BillingManagerStatusLiveData
    fun getSubscriptionDetailsLiveData(subscriptionIDs: List<String>) : LiveData<List<Subscription>>
    fun getSubscriptionPurchases() : PurchasesUpdatedLiveData
}

class SubscriptionRepositoryImpl(private val billingManager: BillingManager, private val purchaseVerifier: PurchaseVerifier) : SubscriptionRepository {

    private val billingManagerStatusLiveData: BillingManagerStatusLiveData = BillingManagerStatusLiveData()
    private val purchasesUpdatedLiveData: PurchasesUpdatedLiveData = PurchasesUpdatedLiveData()

    override fun initiateSubscriptionPurchaseFlow(activity: Activity, subscriptionID: String) {
        billingManager.initiatePurchaseFlow(activity, subscriptionID, BillingClient.SkuType.SUBS)
    }

    override fun verifyPurchase(userID: String, id: String, token: String) {
        purchaseVerifier.verifyPurchase(userID, id, token)
    }

    override fun getSubscriptionStatusLiveData(): BillingManagerStatusLiveData {
        return billingManagerStatusLiveData
    }

    override fun getSubscriptionPurchases() : PurchasesUpdatedLiveData {
        return purchasesUpdatedLiveData
    }

    override fun getSubscriptionDetailsLiveData(subscriptionIDs: List<String>) : LiveData<List<Subscription>> {

        // TODO Cache results

        val subscriptionDetailsLiveData: MutableLiveData<List<Subscription>> = MutableLiveData()

        billingManager.querySkuDetails(BillingClient.SkuType.SUBS, subscriptionIDs) { skuDetailsList ->
            val subscriptions = ArrayList<Subscription>()

            for (skuDetails in skuDetailsList) {
                subscriptions.add(Subscription(skuDetails.sku, skuDetails.title, skuDetails.description, skuDetails.price))
            }

            subscriptionDetailsLiveData.value = subscriptions
        }

        return subscriptionDetailsLiveData
    }
}