package com.appapply.igflexin.billing

import android.app.Activity
import android.content.Context
import android.util.Log
import com.android.billingclient.api.*
import com.appapply.igflexin.common.BillingStatusCode
import com.appapply.igflexin.common.StatusCode

class BillingManager(context: Context) : PurchasesUpdatedListener {

    private val billingClient: BillingClient = BillingClient.newBuilder(context).setListener(this).build()

    private var serviceConnected = false

    private val purchasesUpdatedListeners: ArrayList<PurchasesUpdatedListener> = ArrayList()

    private fun startServiceConnection(action: () -> Unit, onError: (responseCode: Int) -> Unit) {
        billingClient.startConnection(object : BillingClientStateListener {
            override fun onBillingSetupFinished(@BillingClient.BillingResponse billingResponseCode: Int) {
                if (billingResponseCode == BillingClient.BillingResponse.OK) {
                    serviceConnected = true
                    action()
                } else {
                    onError(billingResponseCode)
                }
            }
            override fun onBillingServiceDisconnected() {
                serviceConnected = false
            }
        })
    }

    private fun executeServiceRequest(onError: (responseCode: Int) -> Unit, action: () -> Unit) {
        if (serviceConnected) {
            action()
        } else {
            startServiceConnection(action, onError)
        }
    }

    fun querySkuDetails(@BillingClient.SkuType skuType: String, IDs: List<String>, onSucces: (List<SkuDetails>) -> Unit, onError: (responseCode: Int) -> Unit) {
        executeServiceRequest(onError) {
            val params = SkuDetailsParams.newBuilder()
            params.setSkusList(IDs).setType(skuType)
            billingClient.querySkuDetailsAsync(params.build()) { responseCode, skuDetailsList ->
                if (responseCode == BillingClient.BillingResponse.OK) {
                    onSucces(skuDetailsList)
                } else {
                    onError(responseCode)
                }
            }
        }
    }

    fun initiatePurchaseFlow(activity: Activity, skuID: String, @BillingClient.SkuType skuType: String, onError: (responseCode: Int) -> Unit) {
        executeServiceRequest(onError) {
            val params = BillingFlowParams.newBuilder()
            params.setSku(skuID).setType(skuType)
            val responseCode = billingClient.launchBillingFlow(activity, params.build())
            if (responseCode != BillingClient.BillingResponse.OK) {
                onError(responseCode)
            }
            Log.d("IGFlexin_billing", responseCode.toString())
        }
    }

    override fun onPurchasesUpdated(responseCode: Int, purchases: MutableList<Purchase>?) {
        Log.d("IGFlexin_billing", "onPurchasesUpdated $responseCode, purchases: " + purchases?.size)

        for (purchasesUpdatedListener in purchasesUpdatedListeners) {
            purchasesUpdatedListener.onPurchasesUpdated(responseCode, purchases)
        }
    }

    fun addPurchasesUpdatedListener(listener: PurchasesUpdatedListener) {
        purchasesUpdatedListeners.add(listener)
    }

    fun removePurchasesUpdatedListener(listener: PurchasesUpdatedListener) {
        purchasesUpdatedListeners.remove(listener)
    }

    fun getStatusCodeFromResponseCode(@BillingClient.BillingResponse responseCode: Int): StatusCode {
        return when (responseCode) {
            BillingClient.BillingResponse.BILLING_UNAVAILABLE ->    BillingStatusCode.BILLING_UNAVAILABLE
            BillingClient.BillingResponse.DEVELOPER_ERROR ->        StatusCode.ERROR
            BillingClient.BillingResponse.ERROR ->                  StatusCode.ERROR
            BillingClient.BillingResponse.SERVICE_UNAVAILABLE ->    StatusCode.NETWORK_ERROR
            BillingClient.BillingResponse.SERVICE_DISCONNECTED ->   BillingStatusCode.SERVICE_DISCONNECTED
            BillingClient.BillingResponse.FEATURE_NOT_SUPPORTED ->  BillingStatusCode.FEATURE_NOT_SUPPORTED
            BillingClient.BillingResponse.ITEM_ALREADY_OWNED ->     BillingStatusCode.ITEM_ALREADY_OWNED
            BillingClient.BillingResponse.ITEM_NOT_OWNED ->         BillingStatusCode.ITEM_NOT_OWNED
            BillingClient.BillingResponse.ITEM_UNAVAILABLE ->       BillingStatusCode.ITEM_UNAVAILABLE
            BillingClient.BillingResponse.USER_CANCELED ->          StatusCode.CANCELED
            BillingClient.BillingResponse.OK ->                     StatusCode.SUCCESS
            else -> StatusCode.ERROR
        }
    }
}