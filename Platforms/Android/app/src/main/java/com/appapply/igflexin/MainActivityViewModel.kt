package com.appapply.igflexin

import android.view.MenuItem
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.Transformations
import androidx.lifecycle.ViewModel
import com.appapply.igflexin.events.Event
import com.appapply.igflexin.pojo.OnActivityResultCall
import com.appapply.igflexin.pojo.StartActivityForResultCall
import com.appapply.igflexin.repositories.UserRepository

class MainActivityViewModel(private val userRepository: UserRepository) : ViewModel() {
    private val showProgressBarLiveData: MutableLiveData<Pair<Boolean, Boolean>> = MutableLiveData()
    private val startActivityForResultCallLiveData: MutableLiveData<Event<StartActivityForResultCall>> = MutableLiveData()
    private val onActivityResultCallLiveData: MutableLiveData<Event<OnActivityResultCall>> = MutableLiveData()
    private val snackMessageLiveData: MutableLiveData<Event<String>> = MutableLiveData()
    private val drawerItemSelectedLiveData: MutableLiveData<Event<MenuItem>> = MutableLiveData()
    private val disableBackNavigationLiveData: MutableLiveData<Boolean> = MutableLiveData()
    private val navigateOnActivityLevelLiveData: MutableLiveData<Event<Boolean>> = MutableLiveData()

    private val signedInLiveData = Transformations.map(userRepository.getUserLiveData()) { user -> user.uid != null}
    private val emailVerifiedLiveData = Transformations.map(userRepository.getUserLiveData()) { user -> user.email != null && user.emailVerified != null && user.emailVerified }
    private val subscriptionPurchasedLiveData = MutableLiveData<Boolean>()

    fun showProgressBar(show: Boolean, explicit: Boolean) {
        showProgressBarLiveData.value = Pair(show, explicit)
    }

    fun getShowProgressBarLiveData(): LiveData<Pair<Boolean, Boolean>> {
        return showProgressBarLiveData
    }

    fun getSignedInLiveData(): LiveData<Boolean> {
        return signedInLiveData
    }

    fun getEmailVerifiedLiveData(): LiveData<Boolean> {
        return emailVerifiedLiveData
    }

    fun getSubscriptionPurchasedLiveData() : LiveData<Boolean> {
        subscriptionPurchasedLiveData.value = false
        return subscriptionPurchasedLiveData
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

    fun getSnackMessageLiveData(): LiveData<Event<String>> {
        return snackMessageLiveData
    }

    fun sendDrawerIdItemSelected(item: MenuItem) {
        drawerItemSelectedLiveData.value = Event(item)
    }

    fun getDrawerItemSelectedLiveData(): LiveData<Event<MenuItem>> {
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

    fun getNavigatOnActivityLevelLiveData() : LiveData<Event<Boolean>> {
        return navigateOnActivityLevelLiveData
    }
}