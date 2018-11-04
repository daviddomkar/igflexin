package com.appapply.igflexin

import android.view.MenuItem
import androidx.lifecycle.*
import com.appapply.igflexin.codes.AppStatusCode
import com.appapply.igflexin.codes.StatusCode
import com.appapply.igflexin.events.Event
import com.appapply.igflexin.pojo.*
import com.appapply.igflexin.repositories.AuthRepository
import com.appapply.igflexin.repositories.SubscriptionRepository
import com.appapply.igflexin.repositories.UserRepository

class MainActivityViewModel(private val userRepository: UserRepository, private val subscriptionRepository: SubscriptionRepository, private val authRepository: AuthRepository) : ViewModel() {
    private val showProgressBarLiveData: MutableLiveData<Pair<Boolean, Boolean>> = MutableLiveData()
    private val startActivityForResultCallLiveData: MutableLiveData<Event<StartActivityForResultCall>> = MutableLiveData()
    private val onActivityResultCallLiveData: MutableLiveData<Event<OnActivityResultCall>> = MutableLiveData()
    private val snackMessageLiveData: MutableLiveData<Event<String>> = MutableLiveData()
    private val drawerItemSelectedLiveData: MutableLiveData<Event<MenuItem>> = MutableLiveData()
    private val disableBackNavigationLiveData: MutableLiveData<Boolean> = MutableLiveData()

    private val userLiveData = userRepository.getUserLiveData()
    private val subscriptionInfoLiveData = subscriptionRepository.getSubscriptionInfoLiveData()

    private val signedInLiveData = Transformations.map(userRepository.getUserLiveData()) { user -> Pair(user.status == StatusCode.SUCCESS && user.data != null, user.status == StatusCode.SUCCESS && user.data != null && user.data.emailVerified) }
    private val subscriptionPurchasedLiveData = Transformations.map(subscriptionRepository.getSubscriptionInfoLiveData()) { resource -> resource.status == StatusCode.SUCCESS && resource.data != null && resource.data.verified }

    private val subscriptionVerifiedLiveData = subscriptionRepository.getSubscriptionVerifiedLiveData()
    private val subscriptionQueryLiveData = subscriptionRepository.getSubscriptionQueryLiveData()

    private val igflexinAppStatusLiveData = MediatorLiveData<StatusCode>().also { data ->
        data.addSource(signedInLiveData) { data.value = verifyAppStatus(signedInLiveData, subscriptionPurchasedLiveData )}
        data.addSource(subscriptionPurchasedLiveData) { data.value = verifyAppStatus(signedInLiveData, subscriptionPurchasedLiveData )}
    }

    fun showProgressBar(show: Boolean, explicit: Boolean) {
        showProgressBarLiveData.value = Pair(show, explicit)
    }

    fun setSubsriptionInfoUserID(userID: String) {
        subscriptionRepository.setSubscriptionInfoUserID(userID)
    }

    fun verifySubscriptionPurchase(id: String, token: String) {
        subscriptionRepository.verifyPurchase(id, token)
    }

    fun validateGooglePlaySubscriptions() {
        subscriptionRepository.validateGooglePlaySubscriptions()
    }

    fun getSubscriptionVerifiedLiveData(): LiveData<StatusCode> {
        return subscriptionVerifiedLiveData
    }

    fun getShowProgressBarLiveData() : LiveData<Pair<Boolean, Boolean>> {
        return showProgressBarLiveData
    }

    fun getIGFlexinAppStatusLiveData() : LiveData<StatusCode> {
        return igflexinAppStatusLiveData
    }

    fun startActivityForResultCall() : LiveData<Event<StartActivityForResultCall>> { return  startActivityForResultCallLiveData }

    fun sendStartActivityForResultCall(startActivityForResultCall: StartActivityForResultCall) {
        startActivityForResultCallLiveData.value = Event(startActivityForResultCall)
    }

    fun onActivityResultCall() : LiveData<Event<OnActivityResultCall>> {
        return onActivityResultCallLiveData
    }

    fun sendOnActivityResultCall(onActivityResultCall: OnActivityResultCall) {
        onActivityResultCallLiveData.value = Event(onActivityResultCall)
    }

    fun getSnackMessageLiveData() : LiveData<Event<String>> {
        return snackMessageLiveData
    }

    fun sendDrawerIdItemSelected(item: MenuItem) {
        drawerItemSelectedLiveData.value = Event(item)
    }

    fun getDrawerItemSelectedLiveData() : LiveData<Event<MenuItem>> {
        return drawerItemSelectedLiveData
    }

    fun snack(message: String) {
        snackMessageLiveData.value = Event(message)
    }

    fun disableBackNavigation(disable: Boolean) {
        disableBackNavigationLiveData.value = disable
    }

    fun getDisableBackNavigationLiveData() : LiveData<Boolean>  {
        return disableBackNavigationLiveData
    }

    fun getUserLiveData(): LiveData<Resource<User>> {
        return userLiveData
    }

    fun getSubscriptionInfoLiveData(): LiveData<Resource<SubscriptionInfo>> {
        return subscriptionInfoLiveData
    }

    fun getSubscriptionQueryLiveData() : LiveData<Event<StatusCode>> {
        return subscriptionQueryLiveData
    }

    fun signOut() {
        authRepository.signOut()
    }

    private fun verifyAppStatus(signedInResult: LiveData<Pair<Boolean, Boolean>>, subscriptionPurchasedResult: LiveData<Boolean>) : StatusCode {
        if (signedInResult.value == null) {
            return StatusCode.PENDING
        }

        return when {
            !signedInResult.value!!.first -> AppStatusCode.NOTHING
            !signedInResult.value!!.second -> AppStatusCode.SIGNED_IN
            subscriptionPurchasedResult.value == null -> StatusCode.PENDING
            subscriptionPurchasedResult.value == false -> AppStatusCode.EMAIL_VERIFIED
            else -> AppStatusCode.SUBSCRIPTION_PURCHASED
        }
    }
}