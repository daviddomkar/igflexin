package com.appapply.igflexin

import android.app.Application
import androidx.multidex.MultiDexApplication
import com.appapply.igflexin.koin.modules
import org.koin.android.ext.android.startKoin

class IGFlexin : MultiDexApplication() {

    override fun onCreate() {
        super.onCreate()
        startKoin(this, modules)
    }
}