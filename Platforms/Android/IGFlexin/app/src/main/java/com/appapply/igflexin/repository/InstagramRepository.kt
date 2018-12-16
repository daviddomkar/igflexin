package com.appapply.igflexin.repository

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.appapply.igflexin.billing.Product
import com.appapply.igflexin.common.InstagramStatusCode
import com.appapply.igflexin.common.StatusCode
import com.appapply.igflexin.events.Event
import com.appapply.igflexin.model.InstagramAccount
import com.appapply.igflexin.security.UserKeyManager
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.FirebaseFirestoreException
import com.google.firebase.firestore.Source
import com.google.firebase.functions.FirebaseFunctions
import dev.niekirk.com.instagram4android.Instagram4Android
import dev.niekirk.com.instagram4android.requests.*
import kotlinx.coroutines.*
import java.lang.Exception

interface InstagramRepository {
    val addInstagramAccountStatusLiveData: LiveData<Event<StatusCode>>

    fun addInstagramAccount(nick: String, password: String, subscriptionID: String)

    fun reset()
}

class InstagramRepositoryImpl(private val userKeyManager: UserKeyManager, private val firebaseAuth: FirebaseAuth, private val firestore: FirebaseFirestore, private val functions: FirebaseFunctions) : InstagramRepository {
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

                if (firebaseAuth.currentUser != null) {

                    val uid = firebaseAuth.currentUser!!.uid

                    val key = userKeyManager.retrieveKey(uid)

                    if (key != "none") {
                        Log.d("IGFlexin_instagram", "Have key")
                        addInstagramAccountToDatabase(uid, nick, encryptInstagramAccountPassword(key, password))
                    } else {
                        Log.d("IGFlexin_instagram", "Key is missing")

                        firestore.collection("keys").document(uid).get(Source.CACHE).addOnCompleteListener { cacheTask ->

                            if (cacheTask.isSuccessful && cacheTask.result != null && cacheTask.result!!.exists()) {
                                val keyFromDB = cacheTask.result!!.getString("key")!!

                                val data = HashMap<String, String>()
                                data["key"] = keyFromDB

                                functions.getHttpsCallable("decryptUserKey").call(data).addOnCompleteListener { result ->
                                    if (result.isSuccessful && result.result != null && result.result!!.data != null) {
                                        val data = result.result!!.data as String

                                        userKeyManager.saveKey(uid, data)
                                        addInstagramAccountToDatabase(uid, nick, encryptInstagramAccountPassword(data, password))
                                    } else {
                                        addInstagramAccountStatusMutableLiveData.postValue(Event(StatusCode.ERROR))
                                    }
                                }
                            } else {
                                firestore.collection("keys").document(uid).get(Source.SERVER).addOnCompleteListener { serverTask ->

                                    if (serverTask.isSuccessful && serverTask.result != null && serverTask.result!!.exists()) {
                                        val keyFromDB = serverTask.result!!.getString("key")!!

                                        val data = HashMap<String, String>()
                                        data["key"] = keyFromDB

                                        functions.getHttpsCallable("decryptUserKey").call(data).addOnCompleteListener { result ->
                                            if (result.isSuccessful && result.result != null && result.result!!.data != null) {
                                                val data = result.result!!.data as String

                                                userKeyManager.saveKey(uid, data)
                                                addInstagramAccountToDatabase(uid, nick, encryptInstagramAccountPassword(data, password))
                                            } else {
                                                addInstagramAccountStatusMutableLiveData.postValue(Event(StatusCode.ERROR))
                                            }
                                        }
                                    } else {
                                        if (serverTask.exception != null && serverTask.exception!!.message != null && serverTask.exception!!.message!!.contains("Failed to get documents from server")) {
                                            addInstagramAccountStatusMutableLiveData.postValue(Event(StatusCode.NETWORK_ERROR))
                                        } else {
                                            Log.d("IGFlexin_instagram", "We need to create key hehehe")

                                            functions.getHttpsCallable("createUserKey").call().addOnCompleteListener {
                                                if (it.isSuccessful && it.result != null && it.result!!.data != null) {
                                                    val data = HashMap<String, String>()
                                                    data["key"] = it.result!!.data as String

                                                    functions.getHttpsCallable("decryptUserKey").call(data).addOnCompleteListener { result ->
                                                        if (result.isSuccessful && result.result != null && result.result!!.data != null) {
                                                            val data = result.result!!.data as String

                                                            userKeyManager.saveKey(uid, result.result!!.data!! as String)
                                                            addInstagramAccountToDatabase(uid, nick, encryptInstagramAccountPassword(data, password))
                                                        } else {
                                                            addInstagramAccountStatusMutableLiveData.postValue(Event(StatusCode.ERROR))
                                                        }
                                                    }
                                                } else {
                                                    addInstagramAccountStatusMutableLiveData.postValue(Event(StatusCode.ERROR))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                } else {
                    addInstagramAccountStatusMutableLiveData.postValue(Event(StatusCode.ERROR))
                    return@launch
                }

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

    private fun encryptInstagramAccountPassword(key: String, password: String): String {
        return AESProcessor.encrypt(password, key)
    }

    private fun addInstagramAccountToDatabase(userID: String, username: String, encryptedPassword: String) {
        firestore.collection("accounts").document(username).set(InstagramAccount(username, encryptedPassword, userID)).addOnCompleteListener {
            if (it.isSuccessful) {
                addInstagramAccountStatusMutableLiveData.postValue(Event(StatusCode.SUCCESS))
            } else {
                if (it.exception != null && it.exception is FirebaseFirestoreException && (it.exception as FirebaseFirestoreException).code == FirebaseFirestoreException.Code.PERMISSION_DENIED) {
                    addInstagramAccountStatusMutableLiveData.postValue(Event(InstagramStatusCode.ACCOUNT_ALREADY_ADDED))
                } else {
                    addInstagramAccountStatusMutableLiveData.postValue(Event(StatusCode.ERROR))
                }
            }
        }
    }

    override fun reset() {
        addInstagramAccountStatusMutableLiveData.value = null
    }
}