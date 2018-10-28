package com.appapply.igflexin.billing

import android.util.Log.d
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.appapply.igflexin.codes.StatusCode
import com.google.firebase.functions.FirebaseFunctions

class PurchaseVerifier(private val firebaseFunctions: FirebaseFunctions) {
    private val purchaseVerifiedLiveData = MutableLiveData<StatusCode>()

    fun verifyPurchase(id: String, token: String) {
        purchaseVerifiedLiveData.value = StatusCode.PENDING

        val data = HashMap<String, String>()
        data["subscriptionID"] = id
        data["token"] = token

        firebaseFunctions.getHttpsCallable("verifyGooglePlayPurchase").call(data).addOnCompleteListener {
            if (it.isSuccessful) {
                d("IGFlexin", "Successful " + it.result.toString())
                purchaseVerifiedLiveData.value = StatusCode.SUCCESS
            } else {
                d("IGFlexin", "Error " + it.exception.toString())
                purchaseVerifiedLiveData.value = StatusCode.ERROR
            }
        }
    }

    fun getPurchaseVerifiedLiveData(): LiveData<StatusCode> {
        return purchaseVerifiedLiveData
    }
}