package com.appapply.igflexin.workers

import android.content.Context
import android.util.Log
import androidx.work.Worker
import androidx.work.WorkerParameters
import com.appapply.igflexin.billing.Product
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.functions.FirebaseFunctions
import dev.niekirk.com.instagram4android.Instagram4Android
import dev.niekirk.com.instagram4android.requests.InstagramFollowRequest
import dev.niekirk.com.instagram4android.requests.InstagramGetUserFollowersRequest
import dev.niekirk.com.instagram4android.requests.InstagramSearchUsernameRequest
import dev.niekirk.com.instagram4android.requests.InstagramUnfollowRequest
import org.koin.standalone.KoinComponent
import org.koin.standalone.inject
import java.util.HashMap
import java.util.concurrent.CountDownLatch

class InstagramAccountWorker(context : Context, params : WorkerParameters) : Worker(context, params), KoinComponent {

    private val accountsToFollow = arrayListOf("khloekardashian", "nickyminaj", "katyperry", "taylorswift", "mileycyrcus", "nike", "natgeo", "kendaljenner", "leomessi", "neymarjr", "justinbieber", "kyliejenner", "kimkardashian", "beyonce", "arianagrande", "cristiano", "selenagomez", "instagram", "therock")

    private val firestore: FirebaseFirestore by inject()
    private val functions: FirebaseFunctions by inject()

    override fun doWork(): Result {

        val id = inputData.getLong("id", 0)
        val username = inputData.getString("username")!!
        val password = inputData.getString("password")!!
        val fullName = inputData.getString("fullName")!!
        val photoURL = inputData.getString("photoURL")!!
        val subscriptionID = inputData.getString("subscriptionID")!!

        Log.d("IGFlexin_worker", "Ready to process $username")

        val instagram = Instagram4Android(username, password)
        instagram.setup()

        try {
            val loginResult = instagram.login()

            if (loginResult.error_type != null) {
                updateStatus(id,"bad_password")
                return Result.failure()
            }

            val queryUser = instagram.sendRequest(InstagramSearchUsernameRequest(instagram.username))

            if (subscriptionID == Product.WEEKLY_BASIC_SUBSCRIPTION || subscriptionID == Product.MONTHLY_BASIC_SUBSCRIPTION || subscriptionID == Product.QUARTERLY_BASIC_SUBSCRIPTION || subscriptionID.contains("standard")) {

                val queryFollowers = instagram.sendRequest(InstagramGetUserFollowersRequest(instagram.userId))

                if (queryFollowers.users.count() < 100 || queryUser.user.media_count < 15) {
                    updateStatus(id,"requirements_not_met")
                    return Result.failure()
                }
            }

            updateStatus(id,"running")

            if (queryUser.user.full_name != fullName) {
                updateFullName(id, queryUser.user.full_name)
            }

            if (queryUser.user.profile_pic_url != photoURL) {
                updatePhotoURL(id, queryUser.user.profile_pic_url)
            }

            try {

                Log.d("IGFlexin_worker", "Unfollowing")

                accountsToFollow.forEach {
                    val userResult = instagram.sendRequest(InstagramSearchUsernameRequest(it))
                    instagram.sendRequest(InstagramUnfollowRequest(userResult.user.getPk()))
                }

                Log.d("IGFlexin_worker", "Following")

                accountsToFollow.forEach {
                    val userResult = instagram.sendRequest(InstagramSearchUsernameRequest(it))
                    instagram.sendRequest(InstagramFollowRequest(userResult.user.getPk()))
                }

            } catch (e: Exception) {
                return Result.failure()
            }

            recordStats(id, queryUser.user.follower_count)

        } catch (e: Exception) {
            return Result.retry()
        }

        Log.d("IGFlexin_worker", "Success")

        return Result.success()
    }

    private fun updateStatus(id: Long, status: String) {
        val countDownLatch = CountDownLatch(1)

        val data = HashMap<String, Any>()
        data["status"] = status

        firestore.collection("accounts").document(id.toString()).update(data).addOnCompleteListener {
            countDownLatch.countDown()
        }

        try {
            countDownLatch.await()
        } catch (e: InterruptedException) {}
    }

    private fun updateFullName(id: Long, fullName: String) {
        val countDownLatch = CountDownLatch(1)

        val data = HashMap<String, Any>()
        data["fullName"] = fullName

        firestore.collection("accounts").document(id.toString()).update(data).addOnCompleteListener {
            countDownLatch.countDown()
        }

        try {
            countDownLatch.await()
        } catch (e: InterruptedException) {}
    }

    private fun updatePhotoURL(id: Long, photoURL: String) {
        val countDownLatch = CountDownLatch(1)

        val data = HashMap<String, Any>()
        data["photoURL"] = photoURL

        firestore.collection("accounts").document(id.toString()).update(data).addOnCompleteListener {
            countDownLatch.countDown()
        }

        try {
            countDownLatch.await()
        } catch (e: InterruptedException) {}
    }

    private fun recordStats(id: Long, followers: Int) {
        val countDownLatch = CountDownLatch(1)

        val data = HashMap<String, Any>()
        data["id"] = id
        data["followers"] = followers

        functions.getHttpsCallable("recordStats").call(data).addOnCompleteListener {
            countDownLatch.countDown()
        }

        try {
            countDownLatch.await()
        } catch (e: InterruptedException) {}
    }
}