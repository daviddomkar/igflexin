package com.appapply.igflexin.livedata.billing

import androidx.lifecycle.LiveData
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingClient.BillingResponse
import com.appapply.igflexin.billing.BillingManager
import com.appapply.igflexin.codes.BillingStatusCode
import com.appapply.igflexin.codes.StatusCode
import org.koin.standalone.KoinComponent
import org.koin.standalone.inject

class BillingManagerStatusLiveData : LiveData<StatusCode>(), KoinComponent {
    private val billingManager: BillingManager by inject()

    private val listener = object : BillingManager.BillingStatusListener {
        override fun onBillingResponse(@BillingResponse responseCode: Int) {
            value = when (responseCode) {
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

    override fun onActive() {
        super.onActive()
        billingManager.addStatusListener(listener)
    }

    override fun onInactive() {
        super.onInactive()
        billingManager.removeStatusListener(listener)
    }
}