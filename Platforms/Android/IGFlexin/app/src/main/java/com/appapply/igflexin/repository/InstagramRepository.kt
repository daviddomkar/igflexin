package com.appapply.igflexin.repository

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.appapply.igflexin.billing.Product
import com.appapply.igflexin.common.InstagramStatusCode
import com.appapply.igflexin.common.StatusCode
import com.appapply.igflexin.events.Event
import com.appapply.igflexin.model.InstagramAccount
import com.appapply.igflexin.model.InstagramAccountInfo
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
    fun editInstagramAccount(username: String, password: String)
    fun deleteInstagramAccount(username: String)

    fun pauseInstagramAccount(username: String)
    fun resetInstagramAccount(username: String)

    fun getInstagramAccountInfo(username: String, encryptedPassword: String, onSuccess: (info: InstagramAccountInfo) -> Unit, onError: () -> Unit)

    fun reset()
}

class InstagramRepositoryImpl(private val userKeyManager: UserKeyManager, private val firebaseAuth: FirebaseAuth, private val firestore: FirebaseFirestore, private val functions: FirebaseFunctions) : InstagramRepository {
    private val addInstagramAccountStatusMutableLiveData: MutableLiveData<Event<StatusCode>> = MutableLiveData()

    override val addInstagramAccountStatusLiveData: LiveData<Event<StatusCode>>
        get() = addInstagramAccountStatusMutableLiveData

    override fun addInstagramAccount(nick: String, password: String, subscriptionID: String) {
        addInstagramAccountStatusMutableLiveData.postValue(Event(StatusCode.PENDING))

        if (firebaseAuth.currentUser != null) {
            firestore.collection("accounts").whereEqualTo("userID", firebaseAuth.currentUser!!.uid).get().addOnCompleteListener {
                if (it.isSuccessful) {

                    if (subscriptionID == Product.WEEKLY_BASIC_SUBSCRIPTION || subscriptionID == Product.MONTHLY_BASIC_SUBSCRIPTION || subscriptionID == Product.QUARTERLY_BASIC_SUBSCRIPTION) {
                        if (it.result!!.documents.size >= 1) {
                            addInstagramAccountStatusMutableLiveData.postValue(Event(InstagramStatusCode.RESTRICTED_BY_SUBSCRIPTION_PLAN))
                            return@addOnCompleteListener
                        }
                    } else if(subscriptionID.contains("standard")) {
                        if (it.result!!.documents.size >= 3) {
                            addInstagramAccountStatusMutableLiveData.postValue(Event(InstagramStatusCode.RESTRICTED_BY_SUBSCRIPTION_PLAN))
                            return@addOnCompleteListener
                        }
                    } else if(subscriptionID.contains("business_pro")) {
                        if (it.result!!.documents.size >= 5) {
                            addInstagramAccountStatusMutableLiveData.postValue(Event(InstagramStatusCode.RESTRICTED_BY_SUBSCRIPTION_PLAN))
                            return@addOnCompleteListener
                        }
                    } else if(subscriptionID.contains("business")) {
                        if (it.result!!.documents.size >= 10) {
                            addInstagramAccountStatusMutableLiveData.postValue(Event(InstagramStatusCode.RESTRICTED_BY_SUBSCRIPTION_PLAN))
                            return@addOnCompleteListener
                        }
                    }

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

                            getUserKey({
                                addInstagramAccountToDatabase(firebaseAuth.currentUser!!.uid, nick, encryptInstagramAccountPassword(it, password))
                            }, {
                                addInstagramAccountStatusMutableLiveData.postValue(Event(it))
                            })

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

                } else {
                    addInstagramAccountStatusMutableLiveData.postValue(Event(StatusCode.ERROR))
                }
            }
        } else {
            addInstagramAccountStatusMutableLiveData.postValue(Event(StatusCode.ERROR))
        }
    }

    override fun editInstagramAccount(username: String, password: String) {

        getUserKey({
            firestore.collection("accounts").document(username).update("encryptedPassword", encryptInstagramAccountPassword(it, password))
        }, {})
    }

    override fun deleteInstagramAccount(username: String) {
        firestore.collection("accounts").document(username).delete()
    }

    private fun encryptInstagramAccountPassword(key: String, password: String): String {
        return AESProcessor.encrypt(password, key)
    }

    private fun addInstagramAccountToDatabase(userID: String, username: String, encryptedPassword: String) {
        firestore.collection("accounts").document(username).set(InstagramAccount(username, encryptedPassword, userID, null, null)).addOnCompleteListener {
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

    private fun decryptInstagramAccountPassword(key: String, encryptedPassword: String): String {
        return AESProcessor.decrypt(encryptedPassword, key)
    }

    private fun getUserKey(onSuccess: (key: String) -> Unit, onError: (status: StatusCode) -> Unit) {
            if (firebaseAuth.currentUser != null) {

                val uid = firebaseAuth.currentUser!!.uid

                val key = userKeyManager.retrieveKey(uid)

                if (key != "none") {
                    Log.d("IGFlexin_instagram", "Have key")
                    onSuccess(key)
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
                                    onSuccess(data)
                                } else {
                                    onError(StatusCode.ERROR)
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
                                            onSuccess(data)
                                        } else {
                                            onError(StatusCode.ERROR)
                                        }
                                    }
                                } else {
                                    if (serverTask.exception != null && serverTask.exception!!.message != null && serverTask.exception!!.message!!.contains("Failed to get documents from server")) {
                                        onError(StatusCode.NETWORK_ERROR)
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
                                                        onSuccess(data)
                                                    } else {
                                                        onError(StatusCode.ERROR)
                                                    }
                                                }
                                            } else {
                                                onError(StatusCode.ERROR)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                onError(StatusCode.ERROR)
            }
    }

    override fun pauseInstagramAccount(username: String) {
        val data = HashMap<String, Any>()
        data["status"] = "paused"

        firestore.collection("accounts").document(username).update(data)
    }

    override fun resetInstagramAccount(username: String) {
        val data = HashMap<String, Any?>()
        data["status"] = null

        firestore.collection("accounts").document(username).update(data)
    }

    override fun getInstagramAccountInfo(username: String, encryptedPassword: String, onSuccess: (info: InstagramAccountInfo) -> Unit, onError: () -> Unit) {
        getUserKey({
            GlobalScope.launch {
                val instagram = Instagram4Android.builder().username(username).password(decryptInstagramAccountPassword(it, encryptedPassword)).build()
                instagram.setup()
                try {
                    val loginResult = instagram.login()

                    if (loginResult.error_type != null) {
                        onError()
                        return@launch
                    }

                    val queryUser = instagram.sendRequest(InstagramSearchUsernameRequest(instagram.username))

                    onSuccess(InstagramAccountInfo(username, queryUser.user.full_name, queryUser.user.profile_pic_url))
                } catch(e: Exception) {
                    onError()
                }
            }
        }, {
            onError()
        })
    }

    override fun reset() {
        addInstagramAccountStatusMutableLiveData.value = null
    }
}