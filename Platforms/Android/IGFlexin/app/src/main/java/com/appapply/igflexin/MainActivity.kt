package com.appapply.igflexin

import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import androidx.navigation.NavController
import androidx.navigation.NavDestination
import com.appapply.igflexin.common.OnBackPressedListener
import androidx.navigation.Navigation
import androidx.navigation.fragment.NavHostFragment
import com.appapply.igflexin.common.OnActivityResultObject
import com.appapply.igflexin.common.OnBackPressedFinishListener
import com.appapply.igflexin.events.EventObserver
import kotlinx.android.synthetic.main.activity_main.*
import org.koin.androidx.viewmodel.ext.android.viewModel


class MainActivity : AppCompatActivity(), NavController.OnDestinationChangedListener {

    val viewModel: MainViewModel by viewModel()

    private lateinit var navController: NavController

    override fun onCreate(savedInstanceState: Bundle?) {
        setTheme(R.style.AppTheme)
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val host: NavHostFragment = supportFragmentManager.findFragmentById(R.id.navHostFragment) as NavHostFragment
        navController = host.navController

        navController.addOnDestinationChangedListener(this)

        viewModel.startActivityForResultObjectLiveData.observe(this, EventObserver {
            startActivityForResult(it.intent, it.requestCode)
        })
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        viewModel.onActivityResult(OnActivityResultObject(requestCode, resultCode, data))
    }

    override fun onDestinationChanged(controller: NavController, destination: NavDestination, arguments: Bundle?) {

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
