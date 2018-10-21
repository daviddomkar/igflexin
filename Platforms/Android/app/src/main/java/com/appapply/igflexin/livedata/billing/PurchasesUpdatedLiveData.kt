package com.appapply.igflexin.livedata.billing

import androidx.lifecycle.LiveData
import com.android.billingclient.api.Purchase
import com.appapply.igflexin.billing.BillingManager
import com.appapply.igflexin.events.Event
import org.koin.standalone.KoinComponent
import org.koin.standalone.inject

class PurchasesUpdatedLiveData : LiveData<Event<List<Purchase>>>(), KoinComponent {
    private val billingManager: BillingManager by inject()

    private val listener = object : BillingManager.PurchasesUpdatedListener {
        override fun onPurchasesUpdated(purchases: MutableList<Purchase>?) {
            purchases?.let {
                value = Event(purchases)
            }
        }
    }

    override fun onActive() {
        super.onActive()
        billingManager.addPurchasesUpdatedListener(listener)
    }

    override fun onInactive() {
        super.onInactive()
        billingManager.removePurchasesUpdatedListener(listener)
    }
}