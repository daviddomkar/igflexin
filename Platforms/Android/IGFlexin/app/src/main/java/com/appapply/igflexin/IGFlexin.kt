package com.appapply.igflexin

import android.app.NotificationChannel
import android.app.NotificationManager
import android.graphics.Color
import android.os.Build
import androidx.multidex.MultiDexApplication
import com.appapply.igflexin.koin.modules
import com.google.firebase.firestore.FirebaseFirestore
import org.koin.android.ext.android.startKoin
import com.google.firebase.firestore.FirebaseFirestoreSettings



class IGFlexin : MultiDexApplication() {

    override fun onCreate() {
        super.onCreate()
        startKoin(this, modules)
        setupNotificationChannels()
        val settings = FirebaseFirestoreSettings.Builder()
            .setTimestampsInSnapshotsEnabled(true)
            .build()
        FirebaseFirestore.getInstance().firestoreSettings = settings
    }

    private fun setupNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(getString(R.string.foreground_notification_channel_id), getString(R.string.foreground_notification_channel), NotificationManager.IMPORTANCE_HIGH)

            channel.description = getString(R.string.foreground_notification_channel_description)
            channel.lightColor = Color.LTGRAY

            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager?.createNotificationChannel(channel)
        }
    }
}