package com.appapply.igflexin

import android.util.Log.d
import android.view.MenuItem
import androidx.lifecycle.*
import com.appapply.igflexin.codes.AppStatusCode
import com.appapply.igflexin.codes.StatusCode
import com.appapply.igflexin.events.Event
import com.appapply.igflexin.pojo.OnActivityResultCall
import com.appapply.igflexin.pojo.StartActivityForResultCall
import com.appapply.igflexin.pojo.User
import com.appapply.igflexin.repositories.SubscriptionRepository
import com.appapply.igflexin.repositories.UserRepository

class MainActivityViewModel(private val userRepository: UserRepository, private val subscriptionRepository: SubscriptionRepository) : ViewModel() {
    private val showProgressBarLiveData: MutableLiveData<Pair<Boolean, Boolean>> = MutableLiveData()
    private val startActivityForResultCallLiveData: MutableLiveData<Event<StartActivityForResultCall>> = MutableLiveData()
    private val onActivityResultCallLiveData: MutableLiveData<Event<OnActivityResultCall>> = MutableLiveData()
    private val snackMessageLiveData: MutableLiveData<Event<String>> = MutableLiveData()
    private val drawerItemSelectedLiveData: MutableLiveData<Event<MenuItem>> = MutableLiveData()
    private val disableBackNavigationLiveData: MutableLiveData<Boolean> = MutableLiveData()

    private val userLiveData = userRepository.getUserLiveData()
    private val signedInLiveData = Transformations.map(userRepository.getUserLiveData()) { user -> user.uid != null }
    private val emailVerifiedLiveData = Transformations.map(userRepository.getUserLiveData()) { user -> user.email != null && user.emailVerified != null && user.emailVerified }
    private val subscriptionPurchasedLiveData = MutableLiveData<Boolean>()

    private val igflexinAppStatusLiveData = MediatorLiveData<StatusCode>().also { data ->
        data.addSource(signedInLiveData) { data.value = verifyAppStatus(signedInLiveData, emailVerifiedLiveData, subscriptionPurchasedLiveData )}
        data.addSource(emailVerifiedLiveData) { data.value = verifyAppStatus(signedInLiveData, emailVerifiedLiveData, subscriptionPurchasedLiveData )}
        data.addSource(subscriptionPurchasedLiveData) { data.value = verifyAppStatus(signedInLiveData, emailVerifiedLiveData, subscriptionPurchasedLiveData )}
    }

    fun showProgressBar(show: Boolean, explicit: Boolean) {
        showProgressBarLiveData.value = Pair(show, explicit)
    }

    fun setSubsriptionInfoUserID(userID: String) {
        subscriptionRepository.setSubscriptionInfoUserID(userID)
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

    fun getUserLiveData(): LiveData<User> {
        return userLiveData
    }

    private fun verifyAppStatus(signedInResult: LiveData<Boolean>, emailVerifiedResult: LiveData<Boolean>, subscriptionPurchasedResult: LiveData<Boolean>) : StatusCode {
        if (signedInResult.value == null || emailVerifiedResult.value == null) {
            return StatusCode.PENDING
        }

        return when {
            signedInResult.value == false -> AppStatusCode.NOTHING
            emailVerifiedResult.value == false -> AppStatusCode.SIGNED_IN
            subscriptionPurchasedResult.value == false -> AppStatusCode.EMAIL_VERIFIED
            subscriptionPurchasedResult.value == null -> StatusCode.PENDING
            else -> AppStatusCode.SUBSCRIPTION_PURCHASED
        }
    }
}