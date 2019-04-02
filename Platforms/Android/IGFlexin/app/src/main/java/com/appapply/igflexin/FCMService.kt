package com.appapply.igflexin

import android.util.Log
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import com.appapply.igflexin.workers.InstagramWorker
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class FCMService : FirebaseMessagingService() {
    override fun onMessageReceived(message: RemoteMessage) {
        if (message.data.containsKey("instagram")) {
            when (message.data["instagram"]) {
                "check" -> {
                    Log.d("IGFlexin_worker", "Got request")
                    WorkManager.getInstance().enqueue(
                        OneTimeWorkRequestBuilder<InstagramWorker>().addTag("instagram-check").build()
                    )
                }
            }
        }
    }
}