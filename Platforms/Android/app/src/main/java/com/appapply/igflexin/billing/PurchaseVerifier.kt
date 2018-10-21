package com.appapply.igflexin.billing

import android.util.Log.d
import com.google.firebase.functions.FirebaseFunctions

class PurchaseVerifier(private val firebaseFunctions: FirebaseFunctions) {
    fun verifyPurchase(userID: String, id: String, token: String) {

        val data = HashMap<String, String>()
        data["subscriptionID"] = id
        data["token"] = token

        d("IGFlexin", "Ready to verify $id with user $userID with token $token")

        // TODO Verification

        firebaseFunctions.getHttpsCallable("verifyPurchase").call(data).addOnCompleteListener {
            d("IGFlexin", "Completed")
        }
    }
}