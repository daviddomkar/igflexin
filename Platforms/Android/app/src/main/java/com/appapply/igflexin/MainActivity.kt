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
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.res.ResourcesCompat
import androidx.core.view.GravityCompat
import androidx.drawerlayout.widget.DrawerLayout
import androidx.lifecycle.Observer
import androidx.navigation.NavController
import androidx.navigation.fragment.NavHostFragment
import androidx.navigation.ui.NavigationUI.*
import com.appapply.igflexin.codes.AppStatusCode
import com.appapply.igflexin.codes.StatusCode
import com.appapply.igflexin.codes.SubscriptionStatusCode
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
    private var verificationSent = false
    private var networkError = false
    private var subscriptionNotFound = false
    private var subscriptionNotFoundExecuting = false

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
                R.id.dashboardFragment -> {
                    drawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED)
                    bottomNavView.visibility = View.VISIBLE
                    mainActivityViewModel.disableBackNavigation(false)
                    supportActionBar?.show()
                }
                R.id.instagramAccountManagementFragment -> {
                    d("IGFlexin", "jejda ig")
                    bottomNavView.visibility = View.VISIBLE
                    supportActionBar?.show()
                }
                R.id.subscriptionManagementFragment -> {
                    d("IGFlexin", "jejda sub")
                    bottomNavView.visibility = View.VISIBLE
                    supportActionBar?.show()
                }
                R.id.settingsFragment -> {
                    d("IGFlexin", "jejda settings")
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
                if (it.second) {
                    progressBarHolder.alpha = 1.0f
                    progressBarHolder.visibility = View.VISIBLE
                } else {
                    progressBarHolder.visibility = View.VISIBLE
                    progressBarHolder.animate().setDuration(200).alpha(1.0f).start()
                }
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

        mainActivityViewModel.getUserLiveData().observe(this, Observer {
            if(it.data != null && it.data.emailVerified) {
                d("IGFlexin", "jejda jako hehe")
                mainActivityViewModel.setSubsriptionInfoUserID(it.data.uid)
            }

            if (it.status != StatusCode.SUCCESS) {
                backNavigationDisabled = false
                verificationSent = false
                networkError = false
                subscriptionNotFound = false
                subscriptionNotFoundExecuting = false
            }
        })

        mainActivityViewModel.getSubscriptionVerifiedLiveData().observe(this, Observer {
            verificationSent = false
            when(it) {
                StatusCode.PENDING -> {
                    mainActivityViewModel.showProgressBar(true, false)
                }
                StatusCode.SUCCESS -> {
                    d("IGFlexin", "Verified")
                }
                StatusCode.ERROR -> {
                    mainActivityViewModel.showProgressBar(false, false)
                    showErrorDialog("The server could not verify your purchase.") {
                        finish()
                    }
                }
            }
        })

        mainActivityViewModel.getSubscriptionInfoLiveData().observe(this, Observer {
            d("IGFlexin", "Got something")
            when (it.status) {
                /* NAVIGATION TO SUBSCRIPTION SELECTION IS HANDLED HERE */
                StatusCode.SUCCESS -> {
                    if(it.data != null) {
                        if (!it.data.verified) {
                            mainActivityViewModel.showProgressBar(true, true)
                            mainActivityViewModel.verifySubscriptionPurchase(it.data.subscriptionID, it.data.purchaseToken)
                            verificationSent = true
                        }
                    }
                }
                StatusCode.ERROR -> {
                    d("IGFlexin", "Error subscription")
                    if(!networkError) {
                        networkError = true
                        if (navController.currentDestination?.id != R.id.dashboardFragment && navController.currentDestination?.id != R.id.instagramAccountManagementFragment && navController.currentDestination?.id != R.id.subscriptionManagementFragment)
                            showErrorDialog("Network error.") {
                                finish()
                            }
                    }
                }
                SubscriptionStatusCode.NOT_FOUND -> {
                    d("IGFlexin", "Error finding subscription")

                    if(subscriptionNotFound) {
                        if (navController.currentDestination?.id != R.id.subscriptionSelectionDetailFragment && navController.currentDestination?.id != R.id.subscriptionSelectionFragment)
                            if (!subscriptionNotFoundExecuting)
                                navigateFromLoading(R.id.action_loadingFragment_to_nav_graph_subscription)
                    }
                }
                SubscriptionStatusCode.NOT_FOUND_IN_CACHE -> {
                    d("IGFlexin", "Error finding subscription in cache")
                }
                SubscriptionStatusCode.NOT_FOUND_ON_SERVER -> {
                    d("IGFlexin", "Error finding subscription on server")
                    subscriptionNotFound = true
                    if (navController.currentDestination?.id != R.id.subscriptionSelectionDetailFragment && navController.currentDestination?.id != R.id.subscriptionSelectionFragment)
                        subscriptionNotFound()
                }
            }
        })

        mainActivityViewModel.getIGFlexinAppStatusLiveData().observe(this, Observer {
            //mainActivityViewModel.showProgressBar(false, false)
            when (it) {
                AppStatusCode.NOTHING -> {
                    d("IGFlexin", "Redirecting auth")
                    navigateFromLoading(R.id.action_loadingFragment_to_nav_graph_auth)
                }
                AppStatusCode.SIGNED_IN -> {
                    d("IGFlexin", "Redirecting email")
                    navigateFromLoading(R.id.action_loadingFragment_to_nav_graph_email_verification)
                }
                AppStatusCode.EMAIL_VERIFIED -> {
                    /* NAVIGATION IS HANDLED IN LIVE DATA ABOVE */
                    d("IGFlexin", "Redirecting subs")
                }
                AppStatusCode.SUBSCRIPTION_PURCHASED -> {
                    //mainActivityViewModel.showProgressBar(false, false)
                    d("IGFlexin", "Redirecting app")
                    if (navController.currentDestination?.id != R.id.dashboardFragment && navController.currentDestination?.id != R.id.instagramAccountManagementFragment && navController.currentDestination?.id != R.id.subscriptionManagementFragment)
                        navigateFromLoading(R.id.action_loadingFragment_to_dashboardFragment)
                }
            }
        })

        /*
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
                if (navController.currentDestination?.id != R.id.subscriptionSelectionDetailFragment)
                    navigateFromLoading(R.id.action_loadingFragment_to_nav_graph_subscription)
            }
        })*/
    }

    private fun showErrorDialog(message: String, action: () -> Unit = {}) {
        val dialogBuilder = AlertDialog.Builder(this)

        dialogBuilder.setTitle(getString(R.string.error))
        dialogBuilder.setMessage(message)
        dialogBuilder.setPositiveButton(getString(R.string.ok)) { dialogInterface, _ ->
            action()
            dialogInterface.cancel()
        }

        val dialog = dialogBuilder.create()
        dialog.show()
    }

    private fun subscriptionNotFound() {
        subscriptionNotFoundExecuting = true
        // TODO search for purchases
        navigateFromLoading(R.id.action_loadingFragment_to_nav_graph_subscription)
        subscriptionNotFoundExecuting = false
    }

    private fun navigateFromLoading(@IdRes resId: Int) {
        if (navController.currentDestination?.id == R.id.loadingFragment) {
            navController.navigate(resId)
        } else {
            if (navController.popBackStack(R.id.loadingFragment, false)) {
                navController.navigate(resId)
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
            R.id.instagramAccountManagementFragment -> if (!navController.popBackStack(R.id.dashboardFragment, false)) navController.navigate(R.id.dashboardFragment)
            R.id.subscriptionManagementFragment -> if (!navController.popBackStack(R.id.dashboardFragment, false)) navController.navigate(R.id.dashboardFragment)
            R.id.settingsFragment -> if (!navController.popBackStack(R.id.dashboardFragment, false)) navController.navigate(R.id.dashboardFragment)
            else -> super.onBackPressed()
        }
    }

    override fun onSupportNavigateUp(): Boolean {
        if (backNavigationDisabled) return false

        return when (navController.currentDestination?.id) {
            R.id.welcomeScreenFragment -> false
            R.id.dashboardFragment -> {
                drawerLayout.openDrawer(GravityCompat.START)
                false
            }
            R.id.instagramAccountManagementFragment -> {
                if (!navController.popBackStack(R.id.dashboardFragment, false)) navController.navigate(R.id.dashboardFragment)
                true
            }
            R.id.subscriptionManagementFragment -> {
                if (!navController.popBackStack(R.id.dashboardFragment, false)) navController.navigate(R.id.dashboardFragment)
                true
            }
            R.id.settingsFragment -> {
                if (!navController.popBackStack(R.id.dashboardFragment, false)) navController.navigate(R.id.dashboardFragment)
                true
            }
            else -> navigateUp(drawerLayout, navController)
        }
    }
}

