package com.appapply.igflexin

import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.net.ConnectivityManager
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.lifecycle.Observer
import com.appapply.igflexin.billing.Product
import com.appapply.igflexin.common.InstagramStatusCode
import com.appapply.igflexin.common.StatusCode
import com.appapply.igflexin.common.getStringStatusCode
import com.appapply.igflexin.events.Event
import com.appapply.igflexin.livedata.firebase.FirebaseConnectionLiveData
import com.appapply.igflexin.model.InstagramAccount
import com.appapply.igflexin.security.UserKeyManager
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.ListenerRegistration
import com.google.firebase.firestore.Source
import com.google.firebase.functions.FirebaseFunctions
import dev.niekirk.com.instagram4android.Instagram4Android
import dev.niekirk.com.instagram4android.requests.InstagramFollowRequest
import dev.niekirk.com.instagram4android.requests.InstagramGetUserFollowersRequest
import dev.niekirk.com.instagram4android.requests.InstagramSearchUsernameRequest
import dev.niekirk.com.instagram4android.requests.InstagramUnfollowRequest
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import org.koin.standalone.KoinComponent
import org.koin.standalone.inject
import java.util.*
import kotlin.concurrent.timer

class InstagramJob(private val username: String, private val encryptedPassword: String, val subscriptionID: String, action: (status: StatusCode) -> Unit) : KoinComponent {

    private val functions: FirebaseFunctions by inject()
    private val userKeyManager: UserKeyManager by inject()
    private val firebaseAuth: FirebaseAuth by inject()
    private val firestore: FirebaseFirestore by inject()

    private lateinit var instagram: Instagram4Android

    private var job: Job

    private val accountsToFollow = arrayListOf("khloekardashian", "nickyminaj", "katyperry", "taylorswift", "mileycyrcus", "nike", "natgeo", "kendaljenner", "leomessi", "neymarjr", "justinbieber", "kyliejenner", "kimkardashian", "beyonce", "arianagrande", "cristiano", "selenagomez", "instagram", "therock")

    init {
        job = GlobalScope.launch {
            getUserKey({
                GlobalScope.launch {
                    instagram = Instagram4Android(username, decryptInstagramAccountPassword(it, encryptedPassword))
                    instagram.setup()

                    Log.d("IGFlexin_service", "Elouel3")

                    try {
                        val loginResult = instagram.login()

                        Log.d("IGFlexin_service", "Elouel4")

                        if (loginResult.error_type != null) {
                            action(InstagramStatusCode.BAD_PASSWORD)
                            Log.d("IGFlexin_service", "Error type: " + loginResult.error_type)
                            return@launch
                        }

                        Log.d("IGFlexin_service", "Elouel2")

                        if (subscriptionID == Product.WEEKLY_BASIC_SUBSCRIPTION || subscriptionID == Product.MONTHLY_BASIC_SUBSCRIPTION || subscriptionID == Product.QUARTERLY_BASIC_SUBSCRIPTION || subscriptionID.contains("standard")) {
                            val queryFollowers = instagram.sendRequest(InstagramGetUserFollowersRequest(instagram.userId))
                            val queryUser = instagram.sendRequest(InstagramSearchUsernameRequest(instagram.username))

                            if (queryFollowers.users.count() < 100 || queryUser.user.media_count < 15) {
                                action(InstagramStatusCode.ACCOUNT_DOES_NOT_MEET_REQUIREMENTS)
                                return@launch
                            }
                        }

                        var time: Int = 0

                        Log.d("IGFlexin_service", "Elouel")

                        timer("Action", true, 3000, 1000) {

                            if (time >= 0) {
                                if (time == 0) {
                                    GlobalScope.launch {
                                        accountsToFollow.forEach {

                                            val userResult =
                                                instagram.sendRequest(InstagramSearchUsernameRequest(it))

                                            instagram.sendRequest(InstagramUnfollowRequest(userResult.getUser().getPk()))
                                        }

                                        Log.d("IGFlexin_service", "UnFollowed")

                                        delay((Random().nextInt(4000 - 2000 + 1) + 2000).toLong())

                                        accountsToFollow.forEach {
                                            val userResult =
                                                instagram.sendRequest(InstagramSearchUsernameRequest(it))

                                            instagram.sendRequest(InstagramFollowRequest(userResult.getUser().getPk()))
                                        }

                                        Log.d("IGFlexin_service", "Followed")

                                        time = 1000 * (Random().nextInt(60 * 20 - 60 * 15 + 1) + 60 * 15)
                                        // time = 1000 * (Random().nextInt(60 * 11 - 60 * 9 + 1) + 60 * 9)
                                    }
                                }
                                time -= 1000
                            }
                        }

                    } catch (e: Exception) {
                        Log.d("IGFlexin_service", "Exception: " + e.message)

                        if (e.message == "Unable to resolve host \"i.instagram.com\": No address associated with hostname") {
                            action(StatusCode.NETWORK_ERROR)
                        } else {
                            action(StatusCode.ERROR)
                        }
                    }
                }
            }, {
                action(it)
            })
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
}

class IGFlexinService : Service(), KoinComponent {

    private val firebaseAuth: FirebaseAuth by inject()
    private val firebaseConnectionLiveData: FirebaseConnectionLiveData by inject()

    private val firestore: FirebaseFirestore by inject()

    private val jobs: HashMap<String, InstagramJob> = HashMap()

    private var needRestart = false

    private val authListener = FirebaseAuth.AuthStateListener {
        if (firebaseAuth.currentUser == null) {
            stopSelf()
        }
    }

    private lateinit var paymentListenerRegistration: ListenerRegistration
    private lateinit var accountsListenerRegistration: ListenerRegistration

    private val networkObserver = Observer<Boolean> {
        if (it) {
            if(isNetworkConnected()) {
                val notificationBuilder = getForegroundNotificationBuilder().setContentText(getString(R.string.getting_you_more_followers))
                val notification = notificationBuilder.build()

                notificationManager.notify(1, notification)

                needRestart = false
                restartJobs()
            }
        } else {
            if(!isNetworkConnected()) {
                val notificationBuilder = getForegroundNotificationBuilder().setContentText(getString(R.string.no_internet_connection))
                val notification = notificationBuilder.build()

                notificationManager.notify(1, notification)

                needRestart = true
            }
        }
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    private lateinit var notificationManager: NotificationManager

    override fun onCreate() {
        super.onCreate()
        Log.d("IGFlexin_service", "onCreate")
        notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        val notificationBuilder = getForegroundNotificationBuilder().setContentText(getString(R.string.getting_you_more_followers))
        val notification = notificationBuilder.build()

        startForeground(1, notification)

        firebaseAuth.addAuthStateListener(authListener)

        paymentListenerRegistration = firestore.collection("payments").whereEqualTo("userID", firebaseAuth.currentUser?.uid).limit(1).addSnapshotListener { querySnapshot, firebaseFirestoreException ->
            if (querySnapshot != null && querySnapshot.isEmpty || querySnapshot == null) {
                stopSelf()
            }
        }

        id = UUID.randomUUID().toString()

        startJobs()

        firebaseConnectionLiveData.observeForever(networkObserver)

        accountsListenerRegistration = firestore.collection("accounts").whereEqualTo("userID", firebaseAuth.currentUser?.uid).addSnapshotListener { querySnapshot, firebaseFirestoreException ->
            if (querySnapshot != null && querySnapshot.isEmpty || querySnapshot == null) {
                stopSelf()
            } else {
                // TODO service change
            }
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        super.onStartCommand(intent, flags, startId)
        Log.d("IGFlexin_service", "onStartCommand")
        return START_STICKY
    }

    private fun getForegroundNotificationBuilder(): NotificationCompat.Builder {
        return NotificationCompat.Builder(this, getString(R.string.foreground_notification_channel_id))
            .setContentTitle(getString(R.string.app_name) + " " + getString(R.string.is_now_running))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setSmallIcon(R.drawable.ic_service)
            .setColorized(true)
            .setColor(Color.argb(255, 74, 0, 114))
    }

    override fun onDestroy() {
        super.onDestroy()

        cleanJobs()

        firebaseConnectionLiveData.removeObserver(networkObserver)

        accountsListenerRegistration.remove()
        paymentListenerRegistration.remove()
        firebaseAuth.removeAuthStateListener(authListener)
    }

    private fun startJobs() {
        firestore.collection("accounts").whereEqualTo("userID", firebaseAuth.currentUser?.uid).get().addOnSuccessListener { accountsSnapshot ->
            if (accountsSnapshot.isEmpty) {
                stopSelf()
            } else {
                firestore.collection("payments").whereEqualTo("userID", firebaseAuth.currentUser?.uid).get().addOnSuccessListener { paymentSnapshot ->
                    if (paymentSnapshot.isEmpty) {
                        stopSelf()
                    } else {
                        val subscriptionID = paymentSnapshot.documents[0].getString("subscriptionID")!!

                        val maxJobs = if (subscriptionID == Product.WEEKLY_BASIC_SUBSCRIPTION || subscriptionID == Product.MONTHLY_BASIC_SUBSCRIPTION || subscriptionID == Product.QUARTERLY_BASIC_SUBSCRIPTION) {
                            1
                        } else if(subscriptionID.contains("standard")) {
                            3
                        } else if(subscriptionID.contains("business_pro")) {
                            5
                        } else if(subscriptionID.contains("business")) {
                            10
                        } else {
                            1
                        }

                        var jobsLeft = maxJobs

                        for (accountDocument in accountsSnapshot.documents) {
                            val account = accountDocument.toObject(InstagramAccount::class.java)!!

                            if (jobsLeft > 0) {
                                jobsLeft--

                                val data = HashMap<String, Any>()
                                data["status"] = "running"
                                data["serviceID"] = id

                                firestore.collection("accounts").document(account.username).update(data)

                                jobs[account.username] = InstagramJob(account.username, account.encryptedPassword, subscriptionID) {
                                    // TODO handle errors

                                    Log.d("IGFlexin_service", "error occured: " + getStringStatusCode(it))
                                }
                            } else {
                                val data = HashMap<String, Any>()
                                data["status"] = "subscription_restricted"
                                data["serviceID"] = id

                                firestore.collection("accounts").document(account.username).update(data)
                            }
                        }
                    }
                }
            }
        }
    }

    private fun restartJobs() {

    }

    private fun cleanJobs() {

    }

    private fun isNetworkConnected(): Boolean {
        val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

        return cm.activeNetworkInfo != null
    }

    companion object {
        fun start(context: Context?) {
            if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context!!.startForegroundService(Intent(context, IGFlexinService::class.java))
            }
            else
                context!!.startService(Intent(context, IGFlexinService::class.java))
        }

        private var id: String = ""

        fun getID(): String {
            return id
        }
    }
}