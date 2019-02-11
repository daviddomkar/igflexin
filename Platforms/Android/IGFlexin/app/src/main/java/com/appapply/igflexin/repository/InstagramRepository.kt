package com.appapply.igflexin.repository

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.Transformations
import androidx.work.*
import com.appapply.igflexin.billing.Product
import com.appapply.igflexin.common.InstagramStatusCode
import com.appapply.igflexin.common.Resource
import com.appapply.igflexin.common.StatsPeriod
import com.appapply.igflexin.common.StatusCode
import com.appapply.igflexin.events.Event
import com.appapply.igflexin.livedata.firebase.FirebaseAuthStateLiveData
import com.appapply.igflexin.livedata.firebase.FirebaseFirestoreQueryLiveData
import com.appapply.igflexin.model.InstagramAccount
import com.appapply.igflexin.model.InstagramRecord
import com.appapply.igflexin.security.UserKeyManager
import com.appapply.igflexin.workers.InstagramWorker
import com.google.firebase.Timestamp
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.*
import com.google.firebase.functions.FirebaseFunctions
import dev.niekirk.com.instagram4android.Instagram4Android
import dev.niekirk.com.instagram4android.requests.*
import kotlinx.coroutines.*
import java.lang.Exception
import java.util.*
import java.util.concurrent.TimeUnit

interface InstagramRepository {
    val addInstagramAccountStatusLiveData: LiveData<Event<StatusCode>>
    val editInstagramAccountStatusLiveData: LiveData<Event<StatusCode>>
    val instagramAccountsLiveData: LiveData<Resource<List<InstagramAccount>>>
    val instagramRecordsLiveData: LiveData<Resource<List<InstagramRecord>>>

    fun addInstagramAccount(username: String, password: String, subscriptionID: String)
    fun editInstagramUsername(id: Long, newUsername: String)
    fun editInstagramPassword(id: Long, newPassword: String)
    fun deleteInstagramAccount(id: Long)

    fun pauseInstagramAccount(id: Long)
    fun resetInstagramAccount(id: Long)

    fun updateAccountWorkers(accounts: Iterable<InstagramAccount>)

    fun setRecordsIDAndPeriod(id: Long, period: Int)

    fun reset()
}

class InstagramRepositoryImpl(private val userKeyManager: UserKeyManager, private val firebaseAuth: FirebaseAuth, private val firestore: FirebaseFirestore, private val functions: FirebaseFunctions, firebaseAuthStateLiveData: FirebaseAuthStateLiveData) : InstagramRepository {
    private val addInstagramAccountStatusMutableLiveData: MutableLiveData<Event<StatusCode>> = MutableLiveData()
    private val editInstagramAccountStatusMutableLiveData: MutableLiveData<Event<StatusCode>> = MutableLiveData()

    private val instagramAccountsMutableLiveData: LiveData<Resource<List<InstagramAccount>>> = Transformations.map(Transformations.switchMap(firebaseAuthStateLiveData) {
            FirebaseFirestoreQueryLiveData(MetadataChanges.INCLUDE, firestore.collection("accounts").whereEqualTo("userID", it.currentUser?.uid))
        }) {
            var resource = Resource<List<InstagramAccount>>(StatusCode.ERROR, null)

            if (it.data != null) {
                val accounts = it.data.documents.map {
                    it.toObject(InstagramAccount::class.java)!!
                }

                resource = Resource(StatusCode.SUCCESS, accounts)
            }

            resource
        }
    private val instagramRecordsFirebaseFirestoreQueryLiveData = FirebaseFirestoreQueryLiveData(MetadataChanges.INCLUDE, null)
    private val instagramRecordsMutableLiveData: LiveData<Resource<List<InstagramRecord>>> = Transformations.map(instagramRecordsFirebaseFirestoreQueryLiveData) {

        var resource = Resource<List<InstagramRecord>>(StatusCode.ERROR, null)

        if (it.data != null) {
            val records = it.data.documents.map {
                val timestamp = it.getTimestamp("time", DocumentSnapshot.ServerTimestampBehavior.ESTIMATE)!!
                val followers = it.getLong("followers")!!
                InstagramRecord(timestamp, followers)
            }

            resource = Resource(StatusCode.SUCCESS, records)
        }

        resource
    }

    override val addInstagramAccountStatusLiveData: LiveData<Event<StatusCode>>
        get() = addInstagramAccountStatusMutableLiveData

    override val editInstagramAccountStatusLiveData: LiveData<Event<StatusCode>>
        get() = editInstagramAccountStatusMutableLiveData

    override val instagramAccountsLiveData: LiveData<Resource<List<InstagramAccount>>>
        get() = instagramAccountsMutableLiveData

    override val instagramRecordsLiveData: LiveData<Resource<List<InstagramRecord>>>
        get() = instagramRecordsMutableLiveData

    override fun addInstagramAccount(username: String, password: String, subscriptionID: String) {
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
                        val instagram = Instagram4Android.builder().username(username).password(password).build()
                        instagram.setup()

                        try {
                            val loginResult = instagram.login()

                            if (loginResult.error_type != null) {
                                addInstagramAccountStatusMutableLiveData.postValue(Event(InstagramStatusCode.BAD_PASSWORD))
                                Log.d("IGFlexin_instagram", "Error type: " + loginResult.error_type)
                                return@launch
                            }

                            val queryUser = instagram.sendRequest(InstagramSearchUsernameRequest(instagram.username))

                            if (subscriptionID == Product.WEEKLY_BASIC_SUBSCRIPTION || subscriptionID == Product.MONTHLY_BASIC_SUBSCRIPTION || subscriptionID == Product.QUARTERLY_BASIC_SUBSCRIPTION || subscriptionID.contains("standard")) {

                                val queryFollowers = instagram.sendRequest(InstagramGetUserFollowersRequest(instagram.userId))

                                if (queryFollowers.users.count() < 100 || queryUser.user.media_count < 15) {
                                    addInstagramAccountStatusMutableLiveData.postValue(Event(InstagramStatusCode.ACCOUNT_DOES_NOT_MEET_REQUIREMENTS))
                                    return@launch
                                }
                            }

                            getUserKey({
                                addInstagramAccountToDatabase(firebaseAuth.currentUser!!.uid, queryUser.user.pk, username, queryUser.user.full_name, encryptInstagramAccountPassword(it, password), queryUser.user.profile_pic_url)
                            }, {
                                addInstagramAccountStatusMutableLiveData.postValue(Event(it))
                            })

                        } catch (e: Exception) {
                            Log.d("IGFlexin_instagram", "Exception: " + e.message)

                            if (e.message == "Unable to resolve host \"i.instagram.com\": No address associated with hostname") {
                                addInstagramAccountStatusMutableLiveData.postValue(Event(StatusCode.NETWORK_ERROR))
                            } else {
                                addInstagramAccountStatusMutableLiveData.postValue(Event(InstagramStatusCode.ERROR))
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

    override fun editInstagramUsername(id: Long, newUsername: String) {
        editInstagramAccountStatusMutableLiveData.postValue(Event(StatusCode.PENDING))

        // 1. Get Instagram account from Firebase
        // 2. Get his password
        // 3. Decrypt the password
        // 4. Try logging him to Instagram
        // 5. If successful, Check if IDs are matching
        // 6. If successful, update data in Firebase

        if (firebaseAuth.currentUser != null) {

            getUserKey({key ->

                firestore.collection("accounts").document(id.toString()).get().addOnCompleteListener {
                    if (it.isSuccessful) {

                        val encryptedPassword = it.result!!.getString("encryptedPassword")!!
                        val status = it.result!!.getString("status")!!

                        GlobalScope.launch {
                            val instagram = Instagram4Android.builder().username(newUsername).password(decryptInstagramAccountPassword(key, encryptedPassword)).build()
                            instagram.setup()

                            try {
                                val loginResult = instagram.login()

                                if (loginResult.error_type != null) {
                                    editInstagramAccountStatusMutableLiveData.postValue(Event(InstagramStatusCode.BAD_PASSWORD))
                                    Log.d("IGFlexin_instagram", "Error type: " + loginResult.error_type)
                                    return@launch
                                }

                                val queryUser = instagram.sendRequest(InstagramSearchUsernameRequest(instagram.username))

                                // 4. Try logging him to Instagram .. done
                                // 5. If successful, Check if IDs are matching
                                // 6. If successful, update data in Firebase

                                if (queryUser.user.pk == id) {
                                    val data = HashMap<String, Any>()
                                    data["username"] = newUsername
                                    data["status"] = "running"

                                    firestore.collection("accounts").document(id.toString()).update(data).addOnCompleteListener {task ->
                                        if (task.isSuccessful) {
                                            editInstagramAccountStatusMutableLiveData.postValue(Event(StatusCode.SUCCESS))
                                        } else {
                                            editInstagramAccountStatusMutableLiveData.postValue(Event(InstagramStatusCode.ERROR))
                                        }
                                    }
                                } else {
                                    editInstagramAccountStatusMutableLiveData.postValue(Event(InstagramStatusCode.ID_NOT_MATCHING))
                                }

                            } catch (e: Exception) {
                                Log.d("IGFlexin_instagram", "Exception: " + e.message)

                                if (e.message == "Unable to resolve host \"i.instagram.com\": No address associated with hostname") {
                                    editInstagramAccountStatusMutableLiveData.postValue(Event(StatusCode.NETWORK_ERROR))
                                } else {
                                    editInstagramAccountStatusMutableLiveData.postValue(Event(InstagramStatusCode.ERROR))
                                }

                                return@launch
                            }
                        }
                    } else {
                        editInstagramAccountStatusMutableLiveData.postValue(Event(StatusCode.ERROR))
                    }
                }
            }, {
                editInstagramAccountStatusMutableLiveData.postValue(Event(it))
            })

        } else {
            editInstagramAccountStatusMutableLiveData.postValue(Event(StatusCode.ERROR))
        }
    }

    override fun editInstagramPassword(id: Long, newPassword: String) {
        editInstagramAccountStatusMutableLiveData.postValue(Event(StatusCode.PENDING))

        // 1. Get Instagram account from Firebase
        // 2. Get his username
        // 4. Try logging him to Instagram
        // 5. If successful, Check if IDs are matching
        // 6. If successful, update data in Firebase (encrypt new password)

        if (firebaseAuth.currentUser != null) {

            getUserKey({key ->

                firestore.collection("accounts").document(id.toString()).get().addOnCompleteListener {
                    if (it.isSuccessful) {

                        val username = it.result!!.getString("username")!!
                        val status = it.result!!.getString("status")!!

                        GlobalScope.launch {
                            val instagram = Instagram4Android.builder().username(username).password(newPassword).build()
                            instagram.setup()

                            try {
                                val loginResult = instagram.login()

                                if (loginResult.error_type != null) {
                                    editInstagramAccountStatusMutableLiveData.postValue(Event(InstagramStatusCode.BAD_PASSWORD))
                                    Log.d("IGFlexin_instagram", "Error type: " + loginResult.error_type)
                                    return@launch
                                }

                                val queryUser = instagram.sendRequest(InstagramSearchUsernameRequest(instagram.username))

                                // 4. Try logging him to Instagram .. done
                                // 5. If successful, Check if IDs are matching
                                // 6. If successful, update data in Firebase (encrypt new password)

                                if (queryUser.user.pk == id) {
                                    val data = HashMap<String, Any>()
                                    data["encryptedPassword"] = encryptInstagramAccountPassword(key, newPassword)
                                    data["status"] = "running"

                                    firestore.collection("accounts").document(id.toString()).update(data).addOnCompleteListener {task ->
                                        if (task.isSuccessful) {
                                            editInstagramAccountStatusMutableLiveData.postValue(Event(StatusCode.SUCCESS))
                                        } else {
                                            editInstagramAccountStatusMutableLiveData.postValue(Event(InstagramStatusCode.ERROR))
                                        }
                                    }
                                } else {
                                    editInstagramAccountStatusMutableLiveData.postValue(Event(InstagramStatusCode.ID_NOT_MATCHING))
                                }

                            } catch (e: Exception) {
                                Log.d("IGFlexin_instagram", "Exception: " + e.message)

                                if (e.message == "Unable to resolve host \"i.instagram.com\": No address associated with hostname") {
                                    editInstagramAccountStatusMutableLiveData.postValue(Event(StatusCode.NETWORK_ERROR))
                                } else {
                                    editInstagramAccountStatusMutableLiveData.postValue(Event(InstagramStatusCode.ERROR))
                                }

                                return@launch
                            }
                        }
                    } else {
                        editInstagramAccountStatusMutableLiveData.postValue(Event(StatusCode.ERROR))
                    }
                }
            }, {
                editInstagramAccountStatusMutableLiveData.postValue(Event(it))
            })

        } else {
            editInstagramAccountStatusMutableLiveData.postValue(Event(StatusCode.ERROR))
        }
    }

    override fun deleteInstagramAccount(id: Long) {
        firestore.collection("accounts").document(id.toString()).delete()
    }

    private fun encryptInstagramAccountPassword(key: String, password: String): String {
        return AESProcessor.encrypt(password, key)
    }

    private fun decryptInstagramAccountPassword(key: String, encryptedPassword: String): String {
        return AESProcessor.decrypt(encryptedPassword, key)
    }

    private fun addInstagramAccountToDatabase(userID: String, id: Long, username: String, fullName: String, encryptedPassword: String, photoURL: String) {
        firestore.collection("accounts").document(id.toString()).set(InstagramAccount(id, username, fullName, encryptedPassword, userID, photoURL, "running")).addOnCompleteListener {
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

    override fun pauseInstagramAccount(id: Long) {
        val data = HashMap<String, Any>()
        data["status"] = "paused"

        firestore.collection("accounts").document(id.toString()).update(data)
    }

    override fun resetInstagramAccount(id: Long) {
        val data = HashMap<String, Any?>()
        data["status"] = "running"

        firestore.collection("accounts").document(id.toString()).update(data)
    }

    override fun updateAccountWorkers(accounts: Iterable<InstagramAccount>) {

        if (accounts.toMutableList().isEmpty()) {
            WorkManager.getInstance().cancelUniqueWork("instagram-check")
        } else {
            WorkManager.getInstance().enqueueUniquePeriodicWork("instagram-check", ExistingPeriodicWorkPolicy.KEEP,
                PeriodicWorkRequestBuilder<InstagramWorker>(20, TimeUnit.MINUTES).addTag("instagram-check").build()
            )
        }
    }

    override fun setRecordsIDAndPeriod(id: Long, period: Int) {
        val cal = Calendar.getInstance()

        when (period) {
            StatsPeriod.DAY -> {
                cal.add(Calendar.HOUR, -24)
            }
            StatsPeriod.WEEK -> {
                cal.add(Calendar.HOUR, -7 * 24)
            }
            StatsPeriod.MONTH -> {
                cal.add(Calendar.HOUR, -7 * 24 * 30)
            }
        }

        val timestamp = Timestamp(cal.time)

        instagramRecordsFirebaseFirestoreQueryLiveData.setQuery(firestore.collection("records").whereEqualTo("id", id).whereGreaterThan("time", timestamp))
    }

    override fun reset() {
        addInstagramAccountStatusMutableLiveData.value = null
        editInstagramAccountStatusMutableLiveData.value = null
    }
}