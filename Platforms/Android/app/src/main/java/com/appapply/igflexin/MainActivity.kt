package com.appapply.igflexin

import android.content.Intent
import android.graphics.Color
import android.os.Build.*
import android.os.Bundle
import android.view.MenuItem
import android.view.View
import android.view.WindowManager
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.res.ResourcesCompat
import androidx.core.view.GravityCompat
import androidx.drawerlayout.widget.DrawerLayout
import androidx.lifecycle.Observer
import androidx.navigation.NavController
import androidx.navigation.fragment.NavHostFragment
import androidx.navigation.ui.NavigationUI.*
import com.appapply.igflexin.events.EventObserver
import com.appapply.igflexin.pojo.OnActivityResultCall
import com.google.android.material.navigation.NavigationView
import com.google.android.material.snackbar.Snackbar

import kotlinx.android.synthetic.main.main_activity.*

import org.koin.androidx.viewmodel.ext.android.viewModel

class MainActivity : AppCompatActivity(), NavigationView.OnNavigationItemSelectedListener {

    private lateinit var navController: NavController

    private val mainActivityViewModel: MainActivityViewModel by viewModel()

    private var backNavigationDisabled = false

    override fun onCreate(savedInstanceState: Bundle?) {
        setTheme(R.style.AppTheme)
        super.onCreate(savedInstanceState)
        setContentView(R.layout.main_activity)
        setSupportActionBar(toolbar)

        val host: NavHostFragment = supportFragmentManager.findFragmentById(R.id.navHostFragment) as NavHostFragment
        navController = host.navController

        setOnNavigationItemSelectedListener(this)

        setupActionBar()
        setupNavigationMenu()
        setupBottomNavMenu()

        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
            window.statusBarColor = Color.TRANSPARENT
        }

        navController.addOnNavigatedListener { _, destination ->

            drawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED)
            supportActionBar?.show()
            bottomNavView.visibility = View.GONE

            when (destination.id) {
                R.id.dashboardFragment -> {
                    drawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED)
                    bottomNavView.visibility = View.VISIBLE
                }
                R.id.welcomeScreenFragment -> {
                    supportActionBar?.hide()
                }
                R.id.signUpFragment -> {
                    supportActionBar?.hide()
                }
                R.id.signInFragment -> {
                    supportActionBar?.hide()
                }
                R.id.howItWorksFragment -> {
                    supportActionBar?.hide()
                }
                R.id.emailVerificationFragment -> {
                    supportActionBar?.hide()
                }
                R.id.instagramAccountManagementFragment -> {
                    bottomNavView.visibility = View.VISIBLE
                }
                R.id.subscriptionManagementFragment -> {
                    bottomNavView.visibility = View.VISIBLE
                }
            }
        }

        mainActivityViewModel.startActivityForResultCall().observe(this, EventObserver {
            startActivityForResult(it.intent, it.requestCode)
        })

        mainActivityViewModel.getSnackMessageLiveData().observe(this, EventObserver {
            val snackbar = Snackbar.make(holderLayout, it, Snackbar.LENGTH_SHORT)
            snackbar.view.setBackgroundColor(ResourcesCompat.getColor(resources, R.color.colorPrimary, null))
            snackbar.show()
        })

        mainActivityViewModel.getSignedInLiveData().observe(this, Observer {
            if (!it) {
                if(navController.currentDestination?.id == R.id.dashboardFragment) {
                    navController.navigate(R.id.action_dashboardFragment_to_nav_graph_auth)
                }
            }
        })

        mainActivityViewModel.getDisableBackNavigationLiveData().observe(this, Observer {
            backNavigationDisabled = it
        })
    }

    private fun setupActionBar() {
        setupActionBarWithNavController(this, navController, drawerLayout)
    }

    private fun setupNavigationMenu() {
        setupWithNavController(navView, navController)
    }

    private fun setupBottomNavMenu() {
        setupWithNavController(bottomNavView, navController)
    }

    override fun onNavigationItemSelected(item: MenuItem): Boolean {
        mainActivityViewModel.sendDrawerIdItemSelected(item)

        drawerLayout.closeDrawer(GravityCompat.START)
        return true
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        mainActivityViewModel.sendOnActivityResultCall(OnActivityResultCall(requestCode, resultCode, data))
    }

    override fun onBackPressed() {
        if (backNavigationDisabled) return

        when (navController.currentDestination?.id) {
            R.id.welcomeScreenFragment -> finish()
            else -> super.onBackPressed()
        }
    }

    override fun onSupportNavigateUp(): Boolean {
        if (backNavigationDisabled) return false

        return when (navController.currentDestination?.id) {
            R.id.welcomeScreenFragment -> false
            else -> navigateUp(drawerLayout, navController)
        }
    }
}

