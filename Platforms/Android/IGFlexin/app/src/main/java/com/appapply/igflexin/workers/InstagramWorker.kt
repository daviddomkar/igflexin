package com.appapply.igflexin.workers

import android.content.Context
import android.util.Log
import androidx.work.*
import com.appapply.igflexin.common.StatusCode
import com.appapply.igflexin.model.InstagramAccount
import com.appapply.igflexin.security.UserKeyManager
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.Source
import com.google.firebase.functions.FirebaseFunctions
import org.koin.standalone.KoinComponent
import org.koin.standalone.inject
import java.util.HashMap
import java.util.concurrent.CountDownLatch

class InstagramWorker(context : Context, params : WorkerParameters) : Worker(context, params), KoinComponent {

    private val firebaseFunctions: FirebaseFunctions by inject()
    private val firebaseAuth: FirebaseAuth by inject()
    private val firestore: FirebaseFirestore by inject()
    private val userKeyManager: UserKeyManager by inject()

    private val countDownLatch = CountDownLatch(1)

    override fun doWork(): Result {

        Log.d("IGFlexin_worker", "Initiating work")

        if (firebaseAuth.currentUser != null) {

            var result = Result.retry()
            val uid = firebaseAuth.currentUser!!.uid

            firestore.collection("accounts").whereEqualTo("userID", uid).get(Source.SERVER).addOnCompleteListener {

                if (it.isSuccessful) {
                    val documents = it.result!!.documents

                    firebaseFunctions.getHttpsCallable("canRunWorker").call().addOnCompleteListener {
                        if (it.isSuccessful) {

                            Log.d("IGFlexin_worker", "Can run safely")

                            getUserKey({key ->

                                firestore.collection("payments").whereEqualTo("userID", uid).limit(1).get(Source.SERVER).addOnCompleteListener {
                                    if (it.isSuccessful) {

                                        val subscriptionID = it.result!!.documents[0].getString("subscriptionID")!!

                                        val accounts = ArrayList<InstagramAccount>()

                                        documents.iterator().forEach {
                                            val account = it.toObject(InstagramAccount::class.java)!!

                                            if (account.status == "running" || account.status == "requirements_not_met") {
                                                accounts.add(account)
                                            }
                                        }

                                        val workerRequests = ArrayList<OneTimeWorkRequest>()

                                        accounts.iterator().forEach {
                                            workerRequests.add(OneTimeWorkRequestBuilder<InstagramAccountWorker>().setInputData(
                                                Data.Builder()
                                                    .putLong("id", it.id)
                                                    .putString("username", it.username)
                                                    .putString("password", decryptInstagramAccountPassword(key, it.encryptedPassword))
                                                    .putString("fullName", it.fullName)
                                                    .putString("photoURL", it.photoURL)
                                                    .putString("subscriptionID", subscriptionID)
                                                    .build()
                                            ).build())
                                        }

                                        if (!workerRequests.isEmpty()) {
                                            WorkManager.getInstance().enqueue(workerRequests)
                                        }

                                        result = Result.success()
                                        countDownLatch.countDown()
                                    } else {
                                        result = Result.failure()
                                        countDownLatch.countDown()
                                    }
                                }

                            }, {
                                result = Result.failure()
                                countDownLatch.countDown()
                            })

                        } else {

                            Log.d("IGFlexin_worker", "Too early")

                            result = Result.failure()
                            countDownLatch.countDown()
                        }
                    }
                } else {
                    countDownLatch.countDown()
                }
            }

            try {
                countDownLatch.await()
            } catch (e: InterruptedException) {
                e.printStackTrace()
            }

            Log.d("IGFlexin_worker", "Finished")

            return result
        } else {
            return Result.failure()
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

                        firebaseFunctions.getHttpsCallable("decryptUserKey").call(data).addOnCompleteListener { result ->
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

                                firebaseFunctions.getHttpsCallable("decryptUserKey").call(data).addOnCompleteListener { result ->
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

                                    firebaseFunctions.getHttpsCallable("createUserKey").call().addOnCompleteListener {
                                        if (it.isSuccessful && it.result != null && it.result!!.data != null) {
                                            val data = HashMap<String, String>()
                                            data["key"] = it.result!!.data as String

                                            firebaseFunctions.getHttpsCallable("decryptUserKey").call(data).addOnCompleteListener { result ->
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

    private fun decryptInstagramAccountPassword(key: String, encryptedPassword: String): String {
        return AESProcessor.decrypt(encryptedPassword, key)
    }
}