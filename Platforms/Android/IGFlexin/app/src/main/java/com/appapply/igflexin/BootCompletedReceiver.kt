package com.appapply.igflexin

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootCompletedReceiver: BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if ("android.intent.action.BOOT_COMPLETED" == intent.action) {
            Log.d("IGFlexin_broadcaster", "Starting service")
            IGFlexinService.start(context)
        }
    }
}