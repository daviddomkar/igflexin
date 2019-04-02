package com.appapply.igflexin.repository

import android.app.Activity
import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.Transformations
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.Purchase
import com.appapply.igflexin.R
import com.appapply.igflexin.billing.BillingManager
import com.appapply.igflexin.billing.Product
import com.appapply.igflexin.common.Resource
import com.appapply.igflexin.common.StatusCode
import com.appapply.igflexin.events.Event
import com.appapply.igflexin.livedata.billing.PurchasesUpdatedLiveData
import com.appapply.igflexin.livedata.firebase.FirebaseFirestoreGetEventLiveData
import com.appapply.igflexin.livedata.firebase.FirebaseFirestoreQueryLiveData
import com.appapply.igflexin.model.RawSubscriptionBundle
import com.appapply.igflexin.model.RawSubscriptionPeriod
import com.appapply.igflexin.model.Subscription
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.MetadataChanges
import com.google.firebase.firestore.Source
import com.google.firebase.functions.FirebaseFunctions

interface SubscriptionRepository {
    val subscriptionGetServerLiveData: LiveData<Event<Resource<Subscription>>>
    val subscriptionGetCacheLiveData: LiveData<Event<Resource<Subscription>>>
    val subscriptionLiveData: LiveData<Resource<Subscription>>
    val subscriptionPurchaseLiveData: LiveData<StatusCode>
    val subscriptionUpgradeDowngradeLiveData: LiveData<StatusCode>
    val subscriptionVerifiedLiveData: LiveData<StatusCode>
    val subscriptionPurchaseResultLiveData: LiveData<Event<Resource<List<Purchase>>>>
    val subscriptionPeriodsLiveData: LiveData<Resource<List<RawSubscriptionPeriod>>>
    val subscriptionBundlesLiveData: LiveData<Resource<List<RawSubscriptionBundle>>>

    fun checkForSubscription()
    fun checkForSubscriptionInCache()

    fun purchaseSubscription(activity: Activity, ID: String)
    fun upgradeDowngradeSubscription(activity: Activity, oldID: String, ID: String)

    fun getSubscriptionPeriods()
    fun getSubscriptionBundles(IDs: List<String>)

    fun verifySubscription(id: String, token: String)

    fun resetPurchaseLiveData()
}

class FirebaseSubscriptionRepository(private val firebaseAuth: FirebaseAuth, private val firebaseFirestore: FirebaseFirestore, private val firebaseFunctions: FirebaseFunctions, private val billingManager: BillingManager) : SubscriptionRepository {
    private var subscriptionGetServerMutableLiveData = FirebaseFirestoreGetEventLiveData(Source.SERVER, firebaseFirestore.collection("payments").whereEqualTo("userID", firebaseAuth.currentUser?.uid).limit(1))
    private var subscriptionGetCacheMutableLiveData = FirebaseFirestoreGetEventLiveData(Source.CACHE, firebaseFirestore.collection("payments").whereEqualTo("userID", firebaseAuth.currentUser?.uid).limit(1))
    private var subscriptionMutableLiveData = FirebaseFirestoreQueryLiveData(MetadataChanges.INCLUDE, firebaseFirestore.collection("payments").whereEqualTo("userID", firebaseAuth.currentUser?.uid).limit(1))

    private val subscriptionPurchaseMutableLiveData: MutableLiveData<StatusCode> = MutableLiveData()
    private val subscriptionUpgradeDowngradeMutableLiveData: MutableLiveData<StatusCode> = MutableLiveData()
    private val subscriptionVerifiedMutableLiveData: MutableLiveData<StatusCode> = MutableLiveData()

    private val subscriptionPeriodsMutableLiveData: MutableLiveData<Resource<List<RawSubscriptionPeriod>>> = MutableLiveData()
    private val subscriptionBundlesMutableLiveData: MutableLiveData<Resource<List<RawSubscriptionBundle>>> = MutableLiveData()

    private val subscriptionPurchaseResultMutableLiveData = PurchasesUpdatedLiveData()

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
                            subscription = Subscription(content.data.first().id, content.data.first().getString("orderID"), content.data.first().getString("purchaseToken")!!, content.data.first().getString("subscriptionID")!!, content.data.first().getString("userID")!!, content.data.first().getBoolean("verified")!!, content.data.first().getBoolean("autoRenewing"), content.data.first().getBoolean("inGracePeriod"), false)
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
                            subscription = Subscription(content.data.first().id, content.data.first().getString("orderID"), content.data.first().getString("purchaseToken")!!, content.data.first().getString("subscriptionID")!!, content.data.first().getString("userID")!!, content.data.first().getBoolean("verified")!!, content.data.first().getBoolean("autoRenewing"), content.data.first().getBoolean("inGracePeriod"), false)
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
                        subscription = Subscription(it.data.first().id, it.data.first().getString("orderID"), it.data.first().getString("purchaseToken")!!, it.data.first().getString("subscriptionID")!!, it.data.first().getString("userID")!!, it.data.first().getBoolean("verified")!!, it.data.first().getBoolean("autoRenewing"), it.data.first().getBoolean("inGracePeriod"), false)
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

    override val subscriptionBundlesLiveData: LiveData<Resource<List<RawSubscriptionBundle>>>
        get() = subscriptionBundlesMutableLiveData

    override val subscriptionPurchaseLiveData: LiveData<StatusCode>
        get() = subscriptionPurchaseMutableLiveData

    override val subscriptionUpgradeDowngradeLiveData: LiveData<StatusCode>
        get() = subscriptionUpgradeDowngradeMutableLiveData

    override val subscriptionVerifiedLiveData: LiveData<StatusCode>
        get() = subscriptionVerifiedMutableLiveData

    override val subscriptionPurchaseResultLiveData: LiveData<Event<Resource<List<Purchase>>>>
        get() = subscriptionPurchaseResultMutableLiveData

    override fun checkForSubscription() {
        subscriptionMutableLiveData.setQuery(firebaseFirestore.collection("payments").whereEqualTo("userID", firebaseAuth.currentUser?.uid).limit(1))
        subscriptionGetServerMutableLiveData.setQuery(firebaseFirestore.collection("payments").whereEqualTo("userID", firebaseAuth.currentUser?.uid).limit(1))
        subscriptionGetServerMutableLiveData.query()
    }

    override fun checkForSubscriptionInCache() {
        subscriptionMutableLiveData.setQuery(firebaseFirestore.collection("payments").whereEqualTo("userID", firebaseAuth.currentUser?.uid).limit(1))
        subscriptionGetCacheMutableLiveData.setQuery(firebaseFirestore.collection("payments").whereEqualTo("userID", firebaseAuth.currentUser?.uid).limit(1))
        subscriptionGetCacheMutableLiveData.query()
    }

    override fun purchaseSubscription(activity: Activity, ID: String) {
        subscriptionPurchaseMutableLiveData.value = StatusCode.PENDING
        billingManager.initiatePurchaseFlow(activity, ID, BillingClient.SkuType.SUBS) {
            subscriptionPurchaseMutableLiveData.value = billingManager.getStatusCodeFromResponseCode(it)
        }
    }

    override fun upgradeDowngradeSubscription(activity: Activity, oldID: String, ID: String) {
        subscriptionUpgradeDowngradeMutableLiveData.value = StatusCode.PENDING
        billingManager.initiateUpgradeDowngradePurchaseFlow(activity, oldID, ID, BillingClient.SkuType.SUBS) {
            subscriptionUpgradeDowngradeMutableLiveData.value = billingManager.getStatusCodeFromResponseCode(it)
        }
    }

    override fun getSubscriptionPeriods() {
        subscriptionPeriodsMutableLiveData.value = Resource(StatusCode.PENDING, null)
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
            Log.d("IGFlexin_subscription", "Jako jejda subscription periods")
            subscriptionPeriodsMutableLiveData.value = Resource(billingManager.getStatusCodeFromResponseCode(responseCode), null)
        })
    }

    override fun getSubscriptionBundles(IDs: List<String>) {
        subscriptionBundlesMutableLiveData.value = Resource(StatusCode.PENDING, null)
        billingManager.querySkuDetails(BillingClient.SkuType.SUBS, IDs, { list ->
            val sortedList = list.sortedWith(compareBy { getSubscriptionIndex(it.sku) })

            val bundlesList = ArrayList<RawSubscriptionBundle>()

            for (sku in sortedList) {
                bundlesList.add(RawSubscriptionBundle(sku.sku, getSubscriptionBundleTitle(sku.sku), sku.price, getSubscriptionBundleDescription(sku.sku), getSubscriptionBundleRestriction(sku.sku)))
            }

            subscriptionBundlesMutableLiveData.value = Resource(StatusCode.SUCCESS, bundlesList)

        }, { responseCode ->
            Log.d("IGFlexin_subscription", "Jako jejda subscription bundles")
            subscriptionBundlesMutableLiveData.value = Resource(billingManager.getStatusCodeFromResponseCode(responseCode), null)
        })
    }

    override fun verifySubscription(id: String, token: String) {
        subscriptionVerifiedMutableLiveData.value = StatusCode.PENDING

        val data = HashMap<String, String>()
        data["subscriptionID"] = id
        data["token"] = token

        firebaseFunctions.getHttpsCallable("verifyGooglePlayPurchase").call(data).addOnCompleteListener {
            if (it.isSuccessful) {
                Log.d("IGFlexin_subscription", "Successful " + it.result.toString())
                subscriptionVerifiedMutableLiveData.value = StatusCode.SUCCESS
            } else {
                Log.d("IGFlexin_subscription", "Error " + it.exception.toString())
                subscriptionVerifiedMutableLiveData.value = StatusCode.ERROR
            }
        }
    }

    override fun resetPurchaseLiveData() {
        subscriptionPurchaseMutableLiveData.value = null
        subscriptionUpgradeDowngradeMutableLiveData.value = null
        subscriptionVerifiedMutableLiveData.value = null
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

    private fun getSubscriptionBundleTitle(id: String): Int {
        when (id) {
            Product.WEEKLY_BASIC_SUBSCRIPTION,
            Product.MONTHLY_BASIC_SUBSCRIPTION,
            Product.QUARTERLY_BASIC_SUBSCRIPTION        -> return R.string.basic
            Product.WEEKLY_STANDARD_SUBSCRIPTION,
            Product.MONTHLY_STANDARD_SUBSCRIPTION,
            Product.QUARTERLY_STANDARD_SUBSCRIPTION     -> return R.string.standard
            Product.WEEKLY_BUSINESS_SUBSCRIPTION,
            Product.MONTHLY_BUSINESS_SUBSCRIPTION,
            Product.QUARTERLY_BUSINESS_SUBSCRIPTION     -> return R.string.business
            Product.WEEKLY_BUSINESS_PRO_SUBSCRIPTION,
            Product.MONTHLY_BUSINESS_PRO_SUBSCRIPTION,
            Product.QUARTERLY_BUSINESS_PRO_SUBSCRIPTION -> return R.string.business_pro
        }

        return R.string.unknown
    }

    private fun getSubscriptionBundleDescription(id: String): Int {
        when (id) {
            Product.WEEKLY_BASIC_SUBSCRIPTION,
            Product.MONTHLY_BASIC_SUBSCRIPTION,
            Product.QUARTERLY_BASIC_SUBSCRIPTION        -> return R.string.limited_to_one_ig_acc
            Product.WEEKLY_STANDARD_SUBSCRIPTION,
            Product.MONTHLY_STANDARD_SUBSCRIPTION,
            Product.QUARTERLY_STANDARD_SUBSCRIPTION     -> return R.string.up_to_three_ig_accs
            Product.WEEKLY_BUSINESS_SUBSCRIPTION,
            Product.MONTHLY_BUSINESS_SUBSCRIPTION,
            Product.QUARTERLY_BUSINESS_SUBSCRIPTION     -> return R.string.up_to_five_ig_accs
            Product.WEEKLY_BUSINESS_PRO_SUBSCRIPTION,
            Product.MONTHLY_BUSINESS_PRO_SUBSCRIPTION,
            Product.QUARTERLY_BUSINESS_PRO_SUBSCRIPTION -> return R.string.up_to_ten_ig_accs
        }

        return R.string.unknown
    }

    private fun getSubscriptionBundleRestriction(id: String): Int {
        when (id) {
            Product.WEEKLY_BASIC_SUBSCRIPTION,
            Product.MONTHLY_BASIC_SUBSCRIPTION,
            Product.QUARTERLY_BASIC_SUBSCRIPTION        -> return R.string.must_have_100_follows_and_15_posts_restriction
            Product.WEEKLY_STANDARD_SUBSCRIPTION,
            Product.MONTHLY_STANDARD_SUBSCRIPTION,
            Product.QUARTERLY_STANDARD_SUBSCRIPTION     -> return R.string.must_have_100_follows_and_15_posts_restriction
            Product.WEEKLY_BUSINESS_SUBSCRIPTION,
            Product.MONTHLY_BUSINESS_SUBSCRIPTION,
            Product.QUARTERLY_BUSINESS_SUBSCRIPTION     -> return R.string.no_ig_account_restrictions
            Product.WEEKLY_BUSINESS_PRO_SUBSCRIPTION,
            Product.MONTHLY_BUSINESS_PRO_SUBSCRIPTION,
            Product.QUARTERLY_BUSINESS_PRO_SUBSCRIPTION -> return R.string.no_ig_account_restrictions
        }

        return R.string.unknown
    }
}