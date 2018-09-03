package com.appapply.igflexin

import android.app.Application
import com.appapply.igflexin.koin.allModules
import org.koin.android.ext.android.startKoin

class IGFlexinApplication: Application() {
    override fun onCreate() {
        super.onCreate()

        startKoin(this, allModules)
    }
}