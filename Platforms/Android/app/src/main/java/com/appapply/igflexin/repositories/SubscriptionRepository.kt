package com.appapply.igflexin.repositories

import android.app.Activity
import androidx.lifecycle.LiveData
import androidx.lifecycle.MediatorLiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.Transformations
import com.android.billingclient.api.BillingClient
import com.appapply.igflexin.billing.BillingManager
import com.appapply.igflexin.billing.PurchaseVerifier
import com.appapply.igflexin.codes.StatusCode
import com.appapply.igflexin.codes.SubscriptionStatusCode
import com.appapply.igflexin.livedata.billing.BillingManagerStatusLiveData
import com.appapply.igflexin.livedata.billing.PurchasesUpdatedLiveData
import com.appapply.igflexin.livedata.firebase.FirebaseFirestoreQueryLiveData
import com.appapply.igflexin.pojo.DataOrException
import com.appapply.igflexin.pojo.Resource
import com.appapply.igflexin.pojo.Subscription
import com.appapply.igflexin.pojo.SubscriptionInfo
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.FirebaseFirestoreException
import com.google.firebase.firestore.QuerySnapshot
import com.google.firebase.firestore.Source

interface SubscriptionRepository {
    fun initiateSubscriptionPurchaseFlow(activity: Activity, subscriptionID: String)
    fun verifyPurchase(id: String, token: String)
    fun setSubscriptionInfoUserID(id: String)

    fun getSubscriptionStatusLiveData() : BillingManagerStatusLiveData
    fun getSubscriptionDetailsLiveData(subscriptionIDs: List<String>) : LiveData<List<Subscription>>
    fun getSubscriptionPurchasesLiveData() : PurchasesUpdatedLiveData
    fun getSubscriptionVerifiedLiveData() : LiveData<StatusCode>
    fun getSubscriptionInfoLiveData() : LiveData<Resource<SubscriptionInfo>>
}

typealias QuerySnapshotOrException = DataOrException<QuerySnapshot?, Exception?>

class SubscriptionRepositoryImpl(private val billingManager: BillingManager, private val purchaseVerifier: PurchaseVerifier, private val firebaseFirestore: FirebaseFirestore) : SubscriptionRepository {
    private val billingManagerStatusLiveData = BillingManagerStatusLiveData()
    private val purchasesUpdatedLiveData = PurchasesUpdatedLiveData()
    private val purchaseVerifiedLiveData = purchaseVerifier.getPurchaseVerifiedLiveData()

    private val subscriptionInfoUserIdLiveData = MutableLiveData<String>()

    private val subscriptionInfoCachedLiveData = MutableLiveData<QuerySnapshotOrException>()
    private val subscriptionInfoServerLiveData = MutableLiveData<QuerySnapshotOrException>()

    private val subscriptionInfoLiveData = MediatorLiveData<Resource<SubscriptionInfo>>().also { data ->
        data.addSource(Transformations.map(Transformations.switchMap(subscriptionInfoUserIdLiveData) { FirebaseFirestoreQueryLiveData(firebaseFirestore.collection("payments").whereEqualTo("userID", it).limit(1))}) {
            if (it.exception != null) {
                val statusCode: StatusCode = if (it.exception.code == FirebaseFirestoreException.Code.NOT_FOUND) SubscriptionStatusCode.NOT_FOUND else StatusCode.ERROR
                Resource<SubscriptionInfo>(statusCode, null)
            } else {
                if (it.data != null && !it.data.isEmpty && it.data.documents.first() != null) {
                    val document = it.data.documents.first()
                    if (document.getString("type") != null && document.getString("subscriptionID") != null && document.getString("userID") != null && document.getString("purchaseToken") != null && document.getBoolean("verified") != null) {
                        Resource(StatusCode.SUCCESS, SubscriptionInfo(document.getString("type")!!, document.getString("subscriptionID")!!, document.getString("userID")!!, document.getString("purchaseToken")!!, document.getBoolean("verified")!!, it.data.metadata.isFromCache))
                    } else {
                        Resource<SubscriptionInfo>(SubscriptionStatusCode.NOT_FOUND, null)
                    }
                } else {
                    Resource<SubscriptionInfo>(SubscriptionStatusCode.NOT_FOUND, null)
                }
            }
        }) {
            data.value = it
        }

        data.addSource(Transformations.map(subscriptionInfoCachedLiveData) {
            if (it.exception != null) {
                val statusCode: StatusCode = if (it.exception is FirebaseFirestoreException && it.exception.code == FirebaseFirestoreException.Code.NOT_FOUND) SubscriptionStatusCode.NOT_FOUND_IN_CACHE else StatusCode.ERROR
                Resource<SubscriptionInfo>(statusCode, null)
            } else {
                if (it.data != null && !it.data.isEmpty && it.data.documents.first() != null) {
                    val document = it.data.documents.first()
                    if (document.getString("type") != null && document.getString("subscriptionID") != null && document.getString("userID") != null && document.getString("purchaseToken") != null && document.getBoolean("verified") != null) {
                        Resource(StatusCode.SUCCESS, SubscriptionInfo(document.getString("type")!!, document.getString("subscriptionID")!!, document.getString("userID")!!, document.getString("purchaseToken")!!, document.getBoolean("verified")!!, true))
                    } else {
                        Resource<SubscriptionInfo>(SubscriptionStatusCode.NOT_FOUND_IN_CACHE, null)
                    }
                } else {
                    Resource<SubscriptionInfo>(SubscriptionStatusCode.NOT_FOUND_IN_CACHE, null)
                }
            }
        }) {
            data.value = it
        }

        data.addSource(Transformations.map(subscriptionInfoServerLiveData) {
            if (it.exception != null) {
                val statusCode: StatusCode = if (it.exception is FirebaseFirestoreException && it.exception.code == FirebaseFirestoreException.Code.NOT_FOUND) SubscriptionStatusCode.NOT_FOUND_ON_SERVER else StatusCode.ERROR
                Resource<SubscriptionInfo>(statusCode, null)
            } else {
                if (it.data != null && !it.data.isEmpty && it.data.documents.first() != null) {
                    val document = it.data.documents.first()
                    if (document.getString("type") != null && document.getString("subscriptionID") != null && document.getString("userID") != null && document.getString("purchaseToken") != null && document.getBoolean("verified") != null) {
                        Resource(StatusCode.SUCCESS, SubscriptionInfo(document.getString("type")!!, document.getString("subscriptionID")!!, document.getString("userID")!!, document.getString("purchaseToken")!!, document.getBoolean("verified")!!, false))
                    } else {
                        Resource<SubscriptionInfo>(SubscriptionStatusCode.NOT_FOUND_ON_SERVER, null)
                    }
                } else {
                    Resource<SubscriptionInfo>(SubscriptionStatusCode.NOT_FOUND_ON_SERVER, null)
                }
            }
        }) {
            data.value = it
        }
    }

    override fun initiateSubscriptionPurchaseFlow(activity: Activity, subscriptionID: String) {
        billingManager.initiatePurchaseFlow(activity, subscriptionID, BillingClient.SkuType.SUBS)
    }

    override fun verifyPurchase(id: String, token: String) {
        purchaseVerifier.verifyPurchase(id, token)
    }

    override fun setSubscriptionInfoUserID(id: String) {
        subscriptionInfoUserIdLiveData.value = id

        firebaseFirestore.collection("payments").whereEqualTo("userID", id).limit(1).get(Source.CACHE).addOnCompleteListener {
            if (it.exception != null) {
                subscriptionInfoCachedLiveData.value = QuerySnapshotOrException(null, it.exception)
            } else {
                subscriptionInfoCachedLiveData.value = QuerySnapshotOrException(it.result, it.exception)
            }
        }

        firebaseFirestore.collection("payments").whereEqualTo("userID", id).limit(1).get(Source.SERVER).addOnCompleteListener {
            if (it.exception != null) {
                subscriptionInfoServerLiveData.value = QuerySnapshotOrException(null, it.exception)
            } else {
                subscriptionInfoServerLiveData.value = QuerySnapshotOrException(it.result, it.exception)
            }
        }
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

    override fun getSubscriptionInfoLiveData(): LiveData<Resource<SubscriptionInfo>> {
        return subscriptionInfoLiveData
    }
}