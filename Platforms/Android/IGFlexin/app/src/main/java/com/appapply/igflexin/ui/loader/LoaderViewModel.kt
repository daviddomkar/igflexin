package com.appapply.igflexin.ui.loader

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.Transformations
import androidx.lifecycle.ViewModel
import com.appapply.igflexin.common.StatusCode
import com.appapply.igflexin.repository.SubscriptionRepository
import com.appapply.igflexin.repository.UserRepository

class LoaderViewModel(private val userRepository: UserRepository, private val subscriptionRepository: SubscriptionRepository) : ViewModel() {
    val loggedInAndHasEmailVerifiedLiveData: LiveData<Boolean> = Transformations.map(userRepository.userLiveData) { user ->
        user.status == StatusCode.SUCCESS && user.data != null && user.data.emailVerified
    }

    val subscriptionGetServerLiveData = subscriptionRepository.subscriptionGetServerLiveData
    val subscriptionGetCacheLiveData = subscriptionRepository.subscriptionGetCacheLiveData

    var subscriptionPurchasedCalled = false

    fun checkIfUserHasPurchasedSubscription() {
        Log.d("IGFlexin", "Checking subscription")
        subscriptionRepository.checkForSubscription()
    }

    fun checkForPurchasedSubscriptionInCache() {
        Log.d("IGFlexin", "Checking subscription in cache")
        subscriptionRepository.checkForSubscriptionInCache()
    }
}
