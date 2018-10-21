package com.appapply.igflexin.ui.subscriptionselectiondetail

import android.app.Activity
import androidx.lifecycle.LiveData
import androidx.lifecycle.ViewModel
import com.appapply.igflexin.livedata.billing.PurchasesUpdatedLiveData
import com.appapply.igflexin.pojo.Subscription
import com.appapply.igflexin.pojo.User
import com.appapply.igflexin.repositories.SubscriptionRepository
import com.appapply.igflexin.repositories.UserRepository

class SubscriptionSelectionDetailViewModel(private val subscriptionRepository: SubscriptionRepository, private val userRepository: UserRepository) : ViewModel() {
    fun initiateSubscriptionPurchaseFlow(activity: Activity, id: String) {
        subscriptionRepository.initiateSubscriptionPurchaseFlow(activity, id)
    }

    fun verifySubscriptionPurchase(userID: String, id: String, token: String) {
        subscriptionRepository.verifyPurchase(userID, id, token)
    }

    fun getUserLiveData(): LiveData<User> {
        return userRepository.getUserLiveData()
    }

    fun getSubscriptionDetailsLiveData(subscriptionIDs: List<String>): LiveData<List<Subscription>> {
        return subscriptionRepository.getSubscriptionDetailsLiveData(subscriptionIDs)
    }

    fun getSubscriptionPurchases() : PurchasesUpdatedLiveData {
        return subscriptionRepository.getSubscriptionPurchases()
    }
}
