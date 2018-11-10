package com.appapply.igflexin.repository

import android.util.Log
import androidx.annotation.IdRes
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.Transformations
import com.android.billingclient.api.BillingClient
import com.appapply.igflexin.R
import com.appapply.igflexin.billing.BillingManager
import com.appapply.igflexin.billing.Product
import com.appapply.igflexin.common.Resource
import com.appapply.igflexin.common.StatusCode
import com.appapply.igflexin.events.Event
import com.appapply.igflexin.livedata.firebase.FirebaseFirestoreGetEventLiveData
import com.appapply.igflexin.livedata.firebase.FirebaseFirestoreQueryLiveData
import com.appapply.igflexin.model.RawSubscriptionPeriod
import com.appapply.igflexin.model.Subscription
import com.appapply.igflexin.model.SubscriptionPeriod
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.MetadataChanges
import com.google.firebase.firestore.Source

interface SubscriptionRepository {
    val subscriptionGetServerLiveData: LiveData<Event<Resource<Subscription>>>
    val subscriptionGetCacheLiveData: LiveData<Event<Resource<Subscription>>>
    val subscriptionLiveData: LiveData<Resource<Subscription>>
    val subscriptionPeriodsLiveData: LiveData<Resource<List<RawSubscriptionPeriod>>>

    fun checkForSubscription()
    fun checkForSubscriptionInCache()

    fun getSubscriptionPeriods()
}

class FirebaseSubscriptionRepository(private val firebaseAuth: FirebaseAuth, private val firebaseFirestore: FirebaseFirestore, private val billingManager: BillingManager) : SubscriptionRepository {
    private val subscriptionGetServerMutableLiveData = FirebaseFirestoreGetEventLiveData(Source.SERVER, firebaseFirestore.collection("payments").whereEqualTo("userID", firebaseAuth.currentUser?.uid).limit(1))
    private val subscriptionGetCacheMutableLiveData = FirebaseFirestoreGetEventLiveData(Source.CACHE, firebaseFirestore.collection("payments").whereEqualTo("userID", firebaseAuth.currentUser?.uid).limit(1))
    private val subscriptionMutableLiveData = FirebaseFirestoreQueryLiveData(MetadataChanges.INCLUDE, firebaseFirestore.collection("payments").whereEqualTo("userID", firebaseAuth.currentUser?.uid).limit(1))

    private val subscriptionPeriodsMutableLiveData: MutableLiveData<Resource<List<RawSubscriptionPeriod>>> = MutableLiveData()

    override val subscriptionGetServerLiveData: LiveData<Event<Resource<Subscription>>>
        get() = Transformations.map(subscriptionGetServerMutableLiveData) { event ->
            val content = event.getContentIfNotHandled()
            var statusCode = StatusCode.ERROR
            var subscription: Subscription? = null

            if (content != null) {
                Log.d("IGFlexin_subscription", "UserID: " + firebaseAuth.currentUser?.uid)
                if (content.data != null) {
                    if (!content.data.isEmpty) {
                        Log.d("IGFlexin_subscription", "Data: " + content.data.first().getString("purchaseToken"))
                        try {
                            subscription = Subscription(content.data.first().id, content.data.first().getString("orderID"), content.data.first().getString("purchaseToken")!!, content.data.first().getString("subscriptionID")!!, content.data.first().getString("userID")!!, content.data.first().getBoolean("verified")!!, false)
                            statusCode = StatusCode.SUCCESS
                        } catch (e: Exception) {
                            Log.d("IGFlexin_subscription", "Exception data: " + content.exception.toString())
                        }
                    }
                } else {
                    if (content.exception != null) {
                        Log.d("IGFlexin_subscription", "Exception: " + content.exception.toString())

                        content.exception.message?.let {
                            if (it.contains("Failed to get documents from server"))
                                statusCode = StatusCode.NETWORK_ERROR
                        }
                    }
                }
            } else {
                statusCode = StatusCode.PENDING
            }
            Event(Resource(statusCode, subscription))
        }

    override val subscriptionGetCacheLiveData: LiveData<Event<Resource<Subscription>>>
        get() = Transformations.map(subscriptionGetCacheMutableLiveData) { event ->
            val content = event.getContentIfNotHandled()
            var statusCode = StatusCode.ERROR
            var subscription: Subscription? = null

            if (content != null) {
                Log.d("IGFlexin_subscription", "UserID: " + firebaseAuth.currentUser?.uid)
                if (content.data != null) {
                    if (!content.data.isEmpty) {
                        Log.d("IGFlexin_subscription", "Data: " + content.data.first().getString("purchaseToken"))
                        try {
                            subscription = Subscription(content.data.first().id, content.data.first().getString("orderID"), content.data.first().getString("purchaseToken")!!, content.data.first().getString("subscriptionID")!!, content.data.first().getString("userID")!!, content.data.first().getBoolean("verified")!!, true)
                            statusCode = StatusCode.SUCCESS
                        } catch (e: Exception) {
                            Log.d("IGFlexin_subscription", "Exception data: " + content.exception.toString())
                        }
                    }
                }
            } else {
                statusCode = StatusCode.PENDING
            }
            Event(Resource(statusCode, subscription))
        }

    override val subscriptionLiveData: LiveData<Resource<Subscription>>
        get() = Transformations.map(subscriptionMutableLiveData) {
            var statusCode = StatusCode.ERROR
            var subscription: Subscription? = null

            Log.d("IGFlexin_subscription", "UserID: " + firebaseAuth.currentUser?.uid)
            if (it.data != null) {
                if (!it.data.isEmpty) {
                    Log.d("IGFlexin_subscription", "Data: " + it.data.first().getString("purchaseToken"))
                    try {
                        subscription = Subscription(it.data.first().id, it.data.first().getString("orderID"), it.data.first().getString("purchaseToken")!!, it.data.first().getString("subscriptionID")!!, it.data.first().getString("userID")!!, it.data.first().getBoolean("verified")!!, it.data.first().metadata.isFromCache)
                        statusCode = StatusCode.SUCCESS
                    } catch (e: Exception) {
                        Log.d("IGFlexin_subscription", "Exception data: " + it.exception.toString())
                    }
                }
            }

            Resource(statusCode, subscription)
        }

    override val subscriptionPeriodsLiveData: LiveData<Resource<List<RawSubscriptionPeriod>>>
        get() = subscriptionPeriodsMutableLiveData

    override fun checkForSubscription() {
        subscriptionGetServerMutableLiveData.setQuery(firebaseFirestore.collection("payments").whereEqualTo("userID", firebaseAuth.currentUser?.uid).limit(1))
        subscriptionGetServerMutableLiveData.query()
    }

    override fun checkForSubscriptionInCache() {
        subscriptionGetCacheMutableLiveData.setQuery(firebaseFirestore.collection("payments").whereEqualTo("userID", firebaseAuth.currentUser?.uid).limit(1))
        subscriptionGetCacheMutableLiveData.query()
    }

    override fun getSubscriptionPeriods() {
        billingManager.querySkuDetails(BillingClient.SkuType.SUBS, listOf(
            Product.WEEKLY_BASIC_SUBSCRIPTION,
            Product.MONTHLY_BASIC_SUBSCRIPTION,
            Product.QUARTERLY_BASIC_SUBSCRIPTION
        ), { list ->

            val sortedList = list.sortedWith(compareBy { getSubscriptionIndex(it.sku) })

            val periodsList = ArrayList<RawSubscriptionPeriod>()

            for (sku in sortedList) {
                periodsList.add(RawSubscriptionPeriod(sku.sku, getSubscriptionPeriodTitle(sku.sku), sku.price))
            }

            subscriptionPeriodsMutableLiveData.value = Resource(StatusCode.SUCCESS, periodsList)

        }, { responseCode ->
            Log.d("IGFlexin_subscription", "Jako jejda subscriptions")
            subscriptionPeriodsMutableLiveData.value = Resource(billingManager.getStatusCodeFromResponseCode(responseCode), null)
        })
    }

    private fun getSubscriptionIndex(id: String): Int {
        when (id) {
            Product.WEEKLY_BASIC_SUBSCRIPTION           -> return 0
            Product.MONTHLY_BASIC_SUBSCRIPTION          -> return 1
            Product.QUARTERLY_BASIC_SUBSCRIPTION        -> return 2
            Product.WEEKLY_STANDARD_SUBSCRIPTION        -> return 3
            Product.MONTHLY_STANDARD_SUBSCRIPTION       -> return 4
            Product.QUARTERLY_STANDARD_SUBSCRIPTION     -> return 5
            Product.WEEKLY_BUSINESS_SUBSCRIPTION        -> return 6
            Product.MONTHLY_BUSINESS_SUBSCRIPTION       -> return 7
            Product.QUARTERLY_BUSINESS_SUBSCRIPTION     -> return 8
            Product.WEEKLY_BUSINESS_PRO_SUBSCRIPTION    -> return 9
            Product.MONTHLY_BUSINESS_PRO_SUBSCRIPTION   -> return 10
            Product.QUARTERLY_BUSINESS_PRO_SUBSCRIPTION -> return 11
        }

        return 0
    }

    private fun getSubscriptionPeriodTitle(id: String): Int {
        when (id) {
            Product.WEEKLY_BASIC_SUBSCRIPTION           -> return R.string.weekly
            Product.MONTHLY_BASIC_SUBSCRIPTION          -> return R.string.monthly
            Product.QUARTERLY_BASIC_SUBSCRIPTION        -> return R.string.quarterly
        }

        return R.string.unknown
    }
}