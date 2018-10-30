package com.appapply.igflexin.ui.loading

import androidx.lifecycle.*
import com.appapply.igflexin.codes.AppStatusCode
import com.appapply.igflexin.codes.StatusCode
import com.appapply.igflexin.repositories.SubscriptionRepository
import com.appapply.igflexin.repositories.UserRepository

class LoadingViewModel(private val userRepository: UserRepository, private val subscriptionRepository: SubscriptionRepository) : ViewModel() {

    private val signedInLiveData = Transformations.map(userRepository.getUserLiveData()) { user -> user.status == StatusCode.SUCCESS && user.data != null }
    private val emailVerifiedLiveData = Transformations.map(userRepository.getUserLiveData()) { user -> user.status == StatusCode.SUCCESS && user.data != null && user.data.emailVerified }
    private val subscriptionPurchasedLiveData = Transformations.map(subscriptionRepository.getSubscriptionInfoLiveData()) { resource -> resource.status == StatusCode.SUCCESS && resource.data != null && resource.data.verified }

    private val igflexinAppStatusLiveData = MediatorLiveData<StatusCode>().also { data ->
        data.addSource(signedInLiveData) { data.value = verifyAppStatus(signedInLiveData, emailVerifiedLiveData, subscriptionPurchasedLiveData )}
        data.addSource(emailVerifiedLiveData) { data.value = verifyAppStatus(signedInLiveData, emailVerifiedLiveData, subscriptionPurchasedLiveData )}
        data.addSource(subscriptionPurchasedLiveData) { data.value = verifyAppStatus(signedInLiveData, emailVerifiedLiveData, subscriptionPurchasedLiveData )}
    }

    private fun verifyAppStatus(signedInResult: LiveData<Boolean>, emailVerifiedResult: LiveData<Boolean>, subscriptionPurchasedResult: LiveData<Boolean>) : StatusCode {
        if (signedInResult.value == null || emailVerifiedResult.value == null) {
            return StatusCode.PENDING
        }

        return when {
            signedInResult.value == false -> AppStatusCode.NOTHING
            emailVerifiedResult.value == false -> AppStatusCode.SIGNED_IN
            subscriptionPurchasedResult.value == null -> StatusCode.PENDING
            subscriptionPurchasedResult.value == false -> AppStatusCode.EMAIL_VERIFIED
            else -> AppStatusCode.SUBSCRIPTION_PURCHASED
        }
    }

    fun resetIGFlexinAppStatusLiveData() {
        igflexinAppStatusLiveData.value = null
    }

    fun getIGFlexinAppStatusLiveData() : LiveData<StatusCode> {
        return igflexinAppStatusLiveData
    }
}