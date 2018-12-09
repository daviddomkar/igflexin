package com.appapply.igflexin.repository

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.appapply.igflexin.billing.Product
import com.appapply.igflexin.common.InstagramStatusCode
import com.appapply.igflexin.common.StatusCode
import com.appapply.igflexin.events.Event
import dev.niekirk.com.instagram4android.Instagram4Android
import dev.niekirk.com.instagram4android.requests.*
import kotlinx.coroutines.*
import java.lang.Exception

interface InstagramRepository {
    val addInstagramAccountStatusLiveData: LiveData<Event<StatusCode>>

    fun addInstagramAccount(nick: String, password: String, subscriptionID: String)

    fun reset()
}

class InstagramRepositoryImpl : InstagramRepository {
    private val addInstagramAccountStatusMutableLiveData: MutableLiveData<Event<StatusCode>> = MutableLiveData()

    override val addInstagramAccountStatusLiveData: LiveData<Event<StatusCode>>
        get() = addInstagramAccountStatusMutableLiveData

    override fun addInstagramAccount(nick: String, password: String, subscriptionID: String) {
        addInstagramAccountStatusMutableLiveData.postValue(Event(StatusCode.PENDING))

        GlobalScope.launch {
            val instagram = Instagram4Android.builder().username(nick).password(password).build()
            instagram.setup()

            try {
                val loginResult = instagram.login()

                if (loginResult.error_type != null) {
                    addInstagramAccountStatusMutableLiveData.postValue(Event(InstagramStatusCode.BAD_PASSWORD))
                    Log.d("IGFlexin_instagram", "Error type: " + loginResult.error_type)
                    return@launch
                }

                if (subscriptionID == Product.WEEKLY_BASIC_SUBSCRIPTION || subscriptionID == Product.MONTHLY_BASIC_SUBSCRIPTION || subscriptionID == Product.QUARTERLY_BASIC_SUBSCRIPTION || subscriptionID.contains("standard")) {

                    val queryFollowers = instagram.sendRequest(InstagramGetUserFollowersRequest(instagram.userId))
                    val queryUser = instagram.sendRequest(InstagramSearchUsernameRequest(instagram.username))

                    if (queryFollowers.users.count() < 100 || queryUser.user.media_count < 15) {
                        addInstagramAccountStatusMutableLiveData.postValue(Event(InstagramStatusCode.ACCOUNT_DOES_NOT_MEET_REQUIREMENTS))
                        return@launch
                    }
                }

                // TODO Encrypt password and write into database



            } catch (e: Exception) {
                Log.d("IGFlexin_instagram", "Exception: " + e.message)

                if (e.message == "Unable to resolve host \"i.instagram.com\": No address associated with hostname") {
                    addInstagramAccountStatusMutableLiveData.postValue(Event(StatusCode.NETWORK_ERROR))
                } else {
                    addInstagramAccountStatusMutableLiveData.postValue(Event(StatusCode.ERROR))
                }

                return@launch
            }
        }
    }

    override fun reset() {
        addInstagramAccountStatusMutableLiveData.value = null
    }
}