package com.appapply.igflexin

import android.app.Application
import com.appapply.igflexin.koin.modules
import org.koin.android.ext.android.startKoin

class IGFlexin : Application() {

    override fun onCreate() {
        super.onCreate()
        startKoin(this, modules)
    }
}