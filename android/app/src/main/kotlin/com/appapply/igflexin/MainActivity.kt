/* DISCLAIMER: STATEMENTS ARE COMENTED DUE TO OVERRIDE IN FLUTTERSTATUSBARCOLOR CUSTOM FORK AT https://github.com/DEXIT33/flutter_statusbarcolor */

package com.appapply.igflexin

import android.os.Bundle
import android.view.View
import android.view.ViewTreeObserver
import android.view.WindowManager
import android.content.Context

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

import androidx.multidex.MultiDex

class MainActivity: FlutterActivity(), ViewTreeObserver.OnGlobalLayoutListener {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)

    window.setFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS, WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE)
    window.decorView.rootView.viewTreeObserver.addOnGlobalLayoutListener(this)
  }

  override fun onResume() {
    super.onResume()
    window.setFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS, WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE)

    if (window.decorView.systemUiVisibility and View.SYSTEM_UI_FLAG_LAYOUT_STABLE != View.SYSTEM_UI_FLAG_LAYOUT_STABLE || window.decorView.systemUiVisibility and View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION != View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION)
      window.decorView.systemUiVisibility = (window.decorView.systemUiVisibility or View.SYSTEM_UI_FLAG_LAYOUT_STABLE or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION)
  }

  override fun onPause() {
    super.onPause()
    window.setFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS, WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE)

    if (window.decorView.systemUiVisibility and View.SYSTEM_UI_FLAG_LAYOUT_STABLE != View.SYSTEM_UI_FLAG_LAYOUT_STABLE || window.decorView.systemUiVisibility and View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION != View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION)
      window.decorView.systemUiVisibility = (window.decorView.systemUiVisibility or View.SYSTEM_UI_FLAG_LAYOUT_STABLE or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION)
  }

  override fun onGlobalLayout() {
    window.setFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS, WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE)

    if (window.decorView.systemUiVisibility and View.SYSTEM_UI_FLAG_LAYOUT_STABLE != View.SYSTEM_UI_FLAG_LAYOUT_STABLE || window.decorView.systemUiVisibility and View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION != View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION)
      window.decorView.systemUiVisibility = (window.decorView.systemUiVisibility or View.SYSTEM_UI_FLAG_LAYOUT_STABLE or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION)
  }

  override fun onWindowFocusChanged(hasFocus: Boolean) {
    super.onWindowFocusChanged(hasFocus)
    window.setFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS, WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE)

    if (window.decorView.systemUiVisibility and View.SYSTEM_UI_FLAG_LAYOUT_STABLE != View.SYSTEM_UI_FLAG_LAYOUT_STABLE || window.decorView.systemUiVisibility and View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION != View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION)
      window.decorView.systemUiVisibility = (window.decorView.systemUiVisibility or View.SYSTEM_UI_FLAG_LAYOUT_STABLE or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION)
  }

  override fun attachBaseContext(base: Context) {
    super.attachBaseContext(base)
    MultiDex.install(this)
  }
}
