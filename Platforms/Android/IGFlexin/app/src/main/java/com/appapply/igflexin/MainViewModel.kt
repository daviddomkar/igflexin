package com.appapply.igflexin

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.appapply.igflexin.common.OnActivityResultObject
import com.appapply.igflexin.common.StartActivityForResultObject
import com.appapply.igflexin.events.Event

class MainViewModel : ViewModel() {
    private val startActivityForResultObjectMutableLiveData: MutableLiveData<Event<StartActivityForResultObject>> = MutableLiveData()
    private val onActivityResultObjectMutableLiveData: MutableLiveData<Event<OnActivityResultObject>> = MutableLiveData()

    val startActivityForResultObjectLiveData: LiveData<Event<StartActivityForResultObject>> = startActivityForResultObjectMutableLiveData
    val onActivityResultObjectLiveData: LiveData<Event<OnActivityResultObject>> = onActivityResultObjectMutableLiveData

    fun startActivityForResult(startActivityForResultObject: StartActivityForResultObject) {
        startActivityForResultObjectMutableLiveData.value = Event(startActivityForResultObject)
    }

    fun onActivityResult(onActivityResultObjectLiveData: OnActivityResultObject) {
        onActivityResultObjectMutableLiveData.value = Event(onActivityResultObjectLiveData)
    }

}