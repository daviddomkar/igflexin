package com.appapply.igflexin

import androidx.multidex.MultiDexApplication
import com.appapply.igflexin.koin.allModules
import org.koin.android.ext.android.startKoin

class IGFlexinApplication : MultiDexApplication() {
    override fun onCreate() {
        super.onCreate()
        startKoin(this, allModules)
    }
}