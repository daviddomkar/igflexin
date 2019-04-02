package com.appapply.igflexin.livedata.billing

import androidx.lifecycle.LiveData
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.PurchasesUpdatedListener
import com.appapply.igflexin.billing.BillingManager
import com.appapply.igflexin.common.Resource
import com.appapply.igflexin.events.Event
import org.koin.standalone.KoinComponent
import org.koin.standalone.inject

class PurchasesUpdatedLiveData : LiveData<Event<Resource<List<Purchase>>>>(), PurchasesUpdatedListener, KoinComponent {
    private val billingManager: BillingManager by inject()

    override fun onPurchasesUpdated(responseCode: Int, purchases: MutableList<Purchase>?) {
        postValue(Event(Resource(billingManager.getStatusCodeFromResponseCode(responseCode), purchases as List<Purchase>?)))
    }

    override fun onActive() {
        super.onActive()
        billingManager.addPurchasesUpdatedListener(this)
    }

    override fun onInactive() {
        super.onInactive()
        billingManager.removePurchasesUpdatedListener(this)
    }
}