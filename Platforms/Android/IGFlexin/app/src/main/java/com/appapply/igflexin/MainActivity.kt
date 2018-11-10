package com.appapply.igflexin

import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import com.appapply.igflexin.common.OnBackPressedListener
import androidx.navigation.Navigation
import com.appapply.igflexin.common.OnActivityResultObject
import com.appapply.igflexin.common.OnBackPressedFinishListener
import com.appapply.igflexin.events.EventObserver
import kotlinx.android.synthetic.main.activity_main.*
import org.koin.androidx.viewmodel.ext.android.viewModel


class MainActivity : AppCompatActivity() {

    val viewModel: MainViewModel by viewModel()

    override fun onCreate(savedInstanceState: Bundle?) {
        setTheme(R.style.AppTheme)
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        viewModel.startActivityForResultObjectLiveData.observe(this, EventObserver {
            startActivityForResult(it.intent, it.requestCode)
        })
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        viewModel.onActivityResult(OnActivityResultObject(requestCode, resultCode, data))
    }

    override fun onBackPressed() {
        val currentFragment = navHostFragment.childFragmentManager.fragments[0]
        val controller = Navigation.findNavController(this, R.id.navHostFragment)
        if (currentFragment is OnBackPressedListener) {
            if(!(currentFragment as OnBackPressedListener).onBackPressed()) {
                super.onBackPressed()
            } else {
                return
            }
        } else if (currentFragment is OnBackPressedFinishListener) {
            if (!(currentFragment as OnBackPressedFinishListener).onBackPressed()) {
                finish()
            } else {
                return
            }
        }
        else if (!controller.popBackStack())
            finish()
    }
}
