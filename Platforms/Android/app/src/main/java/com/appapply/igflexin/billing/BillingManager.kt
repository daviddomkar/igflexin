package com.appapply.igflexin.billing

import android.app.Activity
import android.content.Context
import com.android.billingclient.api.*
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.BillingClient.BillingResponse

class BillingManager(context: Context) : PurchasesUpdatedListener {

    private val billingClient: BillingClient = BillingClient.newBuilder(context).setListener(this).build()

    private var serviceConnected = false

    private val statusListeners: ArrayList<BillingStatusListener> = ArrayList()
    private val purchasesListeners: ArrayList<PurchasesUpdatedListener> = ArrayList()

    interface BillingStatusListener {
        fun onBillingResponse(@BillingResponse responseCode: Int)
    }

    interface PurchasesUpdatedListener {
        fun onPurchasesUpdated(purchases: MutableList<Purchase>?)
    }

    private fun startServiceConnection(action: () -> Unit) {
        billingClient.startConnection(object : BillingClientStateListener {
            override fun onBillingSetupFinished(@BillingResponse billingResponseCode: Int) {
                if (billingResponseCode == BillingClient.BillingResponse.OK) {
                    serviceConnected = true
                    action()
                }

                notifyStateListeners(billingResponseCode)
            }
            override fun onBillingServiceDisconnected() {
                serviceConnected = false
            }
        })
    }

    private fun executeServiceRequest(action: () -> Unit) {
        if (serviceConnected) {
            action()
        } else {
            startServiceConnection(action)
        }
    }

    override fun onPurchasesUpdated(responseCode: Int, purchases: MutableList<Purchase>?) {
        notifyStateListeners(responseCode)
        if(responseCode == BillingClient.BillingResponse.OK) notifyPurchasesUpdatedListeners(purchases)
    }

    fun initiatePurchaseFlow(activity: Activity, skuID: String, @BillingClient.SkuType skuType: String) {
        executeServiceRequest {
            val params = BillingFlowParams.newBuilder()
            params.setSku(skuID).setType(skuType)
            billingClient.launchBillingFlow(activity, params.build())
        }
    }

    fun querySkuDetails(@BillingClient.SkuType skuType: String, subscriptionIDs: List<String>, action: (List<SkuDetails>) -> Unit) {
        executeServiceRequest {
            val params = SkuDetailsParams.newBuilder()
            params.setSkusList(subscriptionIDs).setType(skuType)
            billingClient.querySkuDetailsAsync(params.build()) { responseCode, skuDetailsList ->
                if (responseCode == BillingClient.BillingResponse.OK) {
                    action(skuDetailsList)
                } else {
                    notifyStateListeners(responseCode)
                }
            }
        }
    }

    fun queryPurchases(@BillingClient.SkuType skuType: String) : Purchase.PurchasesResult {
        return billingClient.queryPurchases(skuType)
    }

    fun addStatusListener(listener: BillingStatusListener) {
        statusListeners.add(listener)
    }

    fun removeStatusListener(listener: BillingStatusListener) {
        statusListeners.remove(listener)
    }

    private fun notifyStateListeners(@BillingResponse responseCode: Int) {
        for (listener in statusListeners) {
            listener.onBillingResponse(responseCode)
        }
    }

    fun addPurchasesUpdatedListener(listener: PurchasesUpdatedListener) {
        purchasesListeners.add(listener)
    }

    fun removePurchasesUpdatedListener(listener: PurchasesUpdatedListener) {
        purchasesListeners.remove(listener)
    }

    private fun notifyPurchasesUpdatedListeners(purchases: MutableList<Purchase>?) {
        for (listener in purchasesListeners) {
            listener.onPurchasesUpdated(purchases)
        }
    }
}