package com.appapply.igflexin

import android.os.Bundle
import android.view.View
import android.view.ViewTreeObserver
import android.content.Context

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

import androidx.multidex.MultiDex

class MainActivity: FlutterActivity(), ViewTreeObserver.OnGlobalLayoutListener {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)

    window.decorView.rootView.viewTreeObserver.addOnGlobalLayoutListener(this)
  }

  override fun onGlobalLayout() {
    window.decorView.systemUiVisibility = (View.SYSTEM_UI_FLAG_LAYOUT_STABLE or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION)
  }

  override fun onWindowFocusChanged(hasFocus: Boolean) {
    super.onWindowFocusChanged(hasFocus)
    window.decorView.systemUiVisibility = (View.SYSTEM_UI_FLAG_LAYOUT_STABLE or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION)
  }

  override fun attachBaseContext(base: Context) {
    super.attachBaseContext(base)
    MultiDex.install(this)
  }
}
