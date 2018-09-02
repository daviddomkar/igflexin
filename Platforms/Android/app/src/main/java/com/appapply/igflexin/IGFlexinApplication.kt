package com.appapply.igflexin

import android.app.Application

import org.koin.android.ext.android.startKoin

import com.appapply.igflexin.koin.allModules

class IGFlexinApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        //startKoin(this, allModules)
    }
}