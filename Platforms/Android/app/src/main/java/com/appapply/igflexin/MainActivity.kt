package com.appapply.igflexin

import android.content.Intent
import android.graphics.Color
import android.os.Build.*
import android.os.Bundle
import android.util.Log.d
import android.view.MenuItem
import android.view.View
import android.view.WindowManager
import androidx.annotation.IdRes
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.res.ResourcesCompat
import androidx.core.view.GravityCompat
import androidx.drawerlayout.widget.DrawerLayout
import androidx.lifecycle.Observer
import androidx.lifecycle.Transformations
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
            bottomNavView.visibility = View.GONE
            supportActionBar?.hide()

            when (destination.id) {
                R.id.loadingFragment -> {

                }
                R.id.dashboardFragment -> {
                    drawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED)
                    bottomNavView.visibility = View.VISIBLE
                    mainActivityViewModel.disableBackNavigation(false)
                    supportActionBar?.show()
                }
                R.id.instagramAccountManagementFragment -> {
                    bottomNavView.visibility = View.VISIBLE
                    supportActionBar?.show()
                }
                R.id.subscriptionManagementFragment -> {
                    bottomNavView.visibility = View.VISIBLE
                    supportActionBar?.show()
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

        mainActivityViewModel.getDisableBackNavigationLiveData().observe(this, Observer {
            backNavigationDisabled = it
        })

        mainActivityViewModel.getShowProgressBarLiveData().observe(this, Observer {
            if (it.first) {
                progressBarHolder.visibility = View.VISIBLE
                progressBarHolder.animate().setDuration(200).alpha(1.0f).start()
            } else {
                if (it.second) {
                    progressBarHolder.alpha = 0.0f
                    progressBarHolder.visibility = View.GONE
                } else {
                    progressBarHolder.animate().setDuration(200).alpha(0.0f).withEndAction {
                        progressBarHolder.visibility = View.GONE
                    }.start()
                }
            }
        })

        val transformation = Transformations.switchMap(mainActivityViewModel.getEmailVerifiedLiveData()) { emailVerified ->
            if (emailVerified) {
                return@switchMap mainActivityViewModel.getSubscriptionPurchasedLiveData()
            } else {
                d("IGFlexin", "going to email")
                navigateFromLoading(R.id.action_loadingFragment_to_nav_graph_email_verification)
                return@switchMap null
            }
        }

        val transformation2 = Transformations.switchMap(mainActivityViewModel.getSignedInLiveData()) { signedIn ->
            if (signedIn) {
                return@switchMap transformation
            } else {
                d("IGFlexin", "going to auth")
                navigateFromLoading(R.id.action_loadingFragment_to_nav_graph_auth)
                return@switchMap null
            }
        }

        transformation2.observe(this, Observer {
            if (it) {
                d("IGFlexin", "going to app")
                navigateFromLoading(R.id.action_loadingFragment_to_nav_graph_app)
            } else {
                d("IGFlexin", "going to subscription")
                navigateFromLoading(R.id.action_loadingFragment_to_nav_graph_subscription)
            }
        })
    }

    private fun navigateFromLoading(@IdRes resId: Int) {
        if (navController.currentDestination?.id == R.id.loadingFragment) {
            navController.navigate(resId)
        } else {
            if (navController.popBackStack(R.id.loadingFragment, false)) {
                navController.navigate(resId)
            } else {
                navController.navigate(R.id.loadingFragment)
                if (navController.currentDestination?.id == R.id.loadingFragment) navController.navigate(resId)
            }
        }
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
            R.id.dashboardFragment -> finish()
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

