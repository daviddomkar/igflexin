package com.appapply.igflexin

import android.view.MenuItem
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.appapply.igflexin.events.Event
import com.appapply.igflexin.pojo.OnActivityResultCall
import com.appapply.igflexin.pojo.StartActivityForResultCall
import com.appapply.igflexin.repositories.AuthRepository

class MainActivityViewModel(private val authRepository: AuthRepository) : ViewModel() {
    private val startActivityForResultCallLiveData: MutableLiveData<Event<StartActivityForResultCall>> = MutableLiveData()
    private val onActivityResultCallLiveData: MutableLiveData<Event<OnActivityResultCall>> = MutableLiveData()
    private val snackMessageLiveData: MutableLiveData<Event<String>> = MutableLiveData()
    private val drawerItemSelectedLiveData: MutableLiveData<Event<MenuItem>> = MutableLiveData()
    private val disableBackNavigationLiveData: MutableLiveData<Boolean> = MutableLiveData()

    fun startActivityForResultCall() : LiveData<Event<StartActivityForResultCall>> {
        return  startActivityForResultCallLiveData
    }

    fun sendStartActivityForResultCall(startActivityForResultCall: StartActivityForResultCall) {
        startActivityForResultCallLiveData.value = Event(startActivityForResultCall)
    }

    fun onActivityResultCall() : LiveData<Event<OnActivityResultCall>> {
        return  onActivityResultCallLiveData
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

    fun getSignedInLiveData() : LiveData<Boolean> {
        return authRepository.getSignedInLiveData()
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
}