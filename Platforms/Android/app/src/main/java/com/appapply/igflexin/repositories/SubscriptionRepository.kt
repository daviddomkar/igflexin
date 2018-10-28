package com.appapply.igflexin.repositories

import android.app.Activity
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.Transformations
import com.android.billingclient.api.BillingClient
import com.appapply.igflexin.billing.BillingManager
import com.appapply.igflexin.billing.PurchaseVerifier
import com.appapply.igflexin.codes.StatusCode
import com.appapply.igflexin.livedata.billing.BillingManagerStatusLiveData
import com.appapply.igflexin.livedata.billing.PurchasesUpdatedLiveData
import com.appapply.igflexin.livedata.firebase.FirebaseFirestoreQueryLiveData
import com.appapply.igflexin.pojo.Subscription
import com.google.firebase.firestore.FirebaseFirestore

interface SubscriptionRepository {
    fun initiateSubscriptionPurchaseFlow(activity: Activity, subscriptionID: String)
    fun verifyPurchase(id: String, token: String)
    fun setSubscriptionInfoUserID(id: String)

    fun getSubscriptionStatusLiveData() : BillingManagerStatusLiveData
    fun getSubscriptionDetailsLiveData(subscriptionIDs: List<String>) : LiveData<List<Subscription>>
    fun getSubscriptionPurchasesLiveData() : PurchasesUpdatedLiveData
    fun getSubscriptionPurchasedStatusLiveData() : LiveData<StatusCode>
    fun getSubscriptionVerifiedLiveData() : LiveData<StatusCode>
    //fun getSubscriptionInfoLiveData() : Live
}

class SubscriptionRepositoryImpl(private val billingManager: BillingManager, private val purchaseVerifier: PurchaseVerifier, private val firebaseFirestore: FirebaseFirestore) : SubscriptionRepository {
    private val billingManagerStatusLiveData = BillingManagerStatusLiveData()
    private val purchasesUpdatedLiveData = PurchasesUpdatedLiveData()
    private val purchaseVerifiedLiveData = purchaseVerifier.getPurchaseVerifiedLiveData()

    private val subscriptionInfoUserIdLiveData = MutableLiveData<String>()
    private val subscriptionInfoLiveData = Transformations.switchMap(subscriptionInfoUserIdLiveData) { FirebaseFirestoreQueryLiveData(firebaseFirestore.collection("payments").whereEqualTo("userID", it).limit(1)) }

    override fun initiateSubscriptionPurchaseFlow(activity: Activity, subscriptionID: String) {
        billingManager.initiatePurchaseFlow(activity, subscriptionID, BillingClient.SkuType.SUBS)
    }

    override fun verifyPurchase(id: String, token: String) {
        purchaseVerifier.verifyPurchase(id, token)
    }

    override fun setSubscriptionInfoUserID(id: String) {
        subscriptionInfoUserIdLiveData.value = id
    }

    override fun getSubscriptionStatusLiveData(): BillingManagerStatusLiveData {
        return billingManagerStatusLiveData
    }

    override fun getSubscriptionPurchasesLiveData() : PurchasesUpdatedLiveData {
        return purchasesUpdatedLiveData
    }

    override fun getSubscriptionVerifiedLiveData(): LiveData<StatusCode> {
        return purchaseVerifiedLiveData
    }

    override fun getSubscriptionDetailsLiveData(subscriptionIDs: List<String>) : LiveData<List<Subscription>> {

        // TODO Probably cache results

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

    override fun getSubscriptionPurchasedStatusLiveData(): LiveData<StatusCode> {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    /*
    override fun getSubscriptionInfoLiveData(): LiveData<Payment?> {
        return subscriptionInfoLiveData
    }*/
}