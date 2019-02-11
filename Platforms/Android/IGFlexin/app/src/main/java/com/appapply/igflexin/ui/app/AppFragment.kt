package com.appapply.igflexin.ui.app

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.MenuItem
import android.view.View
import android.view.ViewGroup
import androidx.appcompat.app.ActionBarDrawerToggle
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.GravityCompat
import androidx.drawerlayout.widget.DrawerLayout
import androidx.lifecycle.Observer
import androidx.navigation.fragment.findNavController
import androidx.viewpager.widget.ViewPager

import com.appapply.igflexin.R
import com.google.android.material.bottomnavigation.BottomNavigationView
import kotlinx.android.synthetic.main.app_fragment.*
import org.koin.androidx.viewmodel.ext.android.sharedViewModel
import com.appapply.igflexin.common.*
import com.appapply.igflexin.model.Subscription


class AppFragment : Fragment(), OnBackPressedFinishListener, BottomNavigationView.OnNavigationItemSelectedListener, ViewPager.OnPageChangeListener {

    private val viewModel: AppViewModel by sharedViewModel()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.app_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        (requireActivity() as AppCompatActivity).setSupportActionBar(toolbar)

        val adapter = AppViewPagerAdapter(requireContext(), childFragmentManager)

        viewPager.adapter = adapter
        viewPager.offscreenPageLimit = adapter.count - 1

        viewPager.addOnPageChangeListener(this)

        bottomNavView.setOnNavigationItemSelectedListener(this)

        bindNavigationDrawer()

        viewModel.subscriptionLiveData.observe(this, Observer {
            updateGracePeriodWarning(it)
        })

        viewModel.connectionLiveData.observe(this, Observer {
            if (it) {
                if (viewModel.subscriptionLiveData.value != null) {
                    updateGracePeriodWarning(viewModel.subscriptionLiveData.value!!)
                } else {
                    warning.visibility = View.GONE
                }
            } else {
                warningText.text = getString(R.string.not_connected_content_unavailable)
                warningButton.visibility = View.GONE
                warning.visibility = View.VISIBLE
            }
        })

        viewModel.userLiveData.observe(this, Observer {
            if (it.status == StatusCode.ERROR) {
                viewModel.userLiveData.removeObservers(this)
                viewModel.subscriptionLiveData.removeObservers(this)
                findNavController().popBackStack()
            }
        })

        viewModel.showProgressBarLiveData.observe(this, Observer {
            if (it.first) {
                drawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED)
                if (it.second) {
                    progressBarHolder.alpha = 1.0f
                    progressBarHolder.visibility = View.VISIBLE
                } else {
                    progressBarHolder.visibility = View.VISIBLE
                    progressBarHolder.animate().setDuration(200).alpha(1.0f).start()
                }
            } else {
                drawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED)
                if (it.second) {
                    progressBarHolder.alpha = 0.0f
                    progressBarHolder.visibility = View.GONE
                } else {
                    progressBarHolder.animate().setDuration(200).alpha(0.0f).withEndAction {
                        try {
                            progressBarHolder.visibility = View.GONE
                        } catch (e: Exception) { }
                    }.start()
                }
            }
        })
    }

    private fun updateGracePeriodWarning(resource: Resource<Subscription>) {
        when (resource.status) {
            StatusCode.SUCCESS -> {
                if (!resource.data!!.verified || (resource.data.autoRenewing != null && !resource.data.autoRenewing)) {
                    viewModel.userLiveData.removeObservers(this)
                    viewModel.subscriptionLiveData.removeObservers(this)
                    viewModel.connectionLiveData.removeObservers(this)
                    findNavController().popBackStack()
                    return
                } else {
                    if (viewModel.connectionLiveData.value != null && viewModel.connectionLiveData.value == true) {
                        if (resource.data.inGracePeriod != null && resource.data.inGracePeriod) {
                            warningText.text = getString(R.string.problem_with_payment_method)
                            warningButton.text = getString(R.string.fix)
                            warningButton.visibility = View.VISIBLE
                            warning.visibility = View.VISIBLE
                            warningButton.setOnClickListener { _ ->
                                val url =
                                    "https://play.google.com/store/account/subscriptions?sku=" + resource.data.subscriptionID + "&package=com.appapply.igflexin"
                                val i = Intent(Intent.ACTION_VIEW)
                                i.data = Uri.parse(url)
                                startActivity(i)
                            }
                        } else {
                            warning.visibility = View.GONE
                        }
                    }
                }
            }
            StatusCode.ERROR -> {
                viewModel.userLiveData.removeObservers(this)
                viewModel.subscriptionLiveData.removeObservers(this)
                viewModel.connectionLiveData.removeObservers(this)
                findNavController().popBackStack()
                return
            }
        }
    }

    override fun onNavigationItemSelected(menuItem: MenuItem): Boolean {
        when (menuItem.itemId) {
            R.id.navigationDashboard -> {
                if (viewPager.currentItem != 0) viewPager.currentItem = 0
                navView.setCheckedItem(R.id.navigationDashboard)
                return true
            }
            R.id.navigationInstagramAccounts -> {
                if (viewPager.currentItem != 1) viewPager.currentItem = 1
                navView.setCheckedItem(R.id.navigationInstagramAccounts)
                return true
            }
            R.id.navigationSubscriptionManagement -> {
                if (viewPager.currentItem != 2) viewPager.currentItem = 2
                navView.setCheckedItem(R.id.navigationSubscriptionManagement)
                return true
            }
        }

        return false
    }

    private fun bindNavigationDrawer() {
        val toggle = ActionBarDrawerToggle(requireActivity(), drawerLayout, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close)

        drawerLayout.addDrawerListener(toggle)
        toggle.syncState()

        navView.setNavigationItemSelectedListener {
            when (it.itemId) {
                R.id.navigationDashboard -> {
                    if (viewPager.currentItem != 0) viewPager.currentItem = 0
                }
                R.id.navigationInstagramAccounts -> {
                    if (viewPager.currentItem != 1) viewPager.currentItem = 1
                }
                R.id.navigationSubscriptionManagement -> {
                    if (viewPager.currentItem != 2) viewPager.currentItem = 2
                }
                R.id.signOutMenuItem -> {
                    viewModel.signOut()
                }
            }

            bottomNavView.selectedItemId = it.itemId
            drawerLayout.closeDrawer(GravityCompat.START)


            true
        }

        onPageSelected(viewPager.currentItem)
    }

    override fun onResume() {
        super.onResume()
        when (viewPager.currentItem) {
            0 -> {
                Log.d("IGFlexin_app", "Selected dashboard")
                toolbar.title = getString(R.string.dashboard)
                navView.setCheckedItem(R.id.navigationDashboard)
                bottomNavView.selectedItemId = R.id.navigationDashboard
            }
            1 -> {
                Log.d("IGFlexin_app", "Selected accounts")
                toolbar.title = getString(R.string.accounts)
                navView.setCheckedItem(R.id.navigationInstagramAccounts)
                bottomNavView.selectedItemId = R.id.navigationInstagramAccounts
            }
            2 -> {
                Log.d("IGFlexin_app", "Selected subscription")
                toolbar.title = getString(R.string.subscription)
                navView.setCheckedItem(R.id.navigationSubscriptionManagement)
                bottomNavView.selectedItemId = R.id.navigationSubscriptionManagement
            }
        }
    }

    override fun onPageScrollStateChanged(state: Int) {

    }

    override fun onPageScrolled(position: Int, positionOffset: Float, positionOffsetPixels: Int) {

    }

    override fun onPageSelected(position: Int) {
        when (position) {
            0 -> {
                Log.d("IGFlexin_app", "Selected dashboard")
                toolbar.title = getString(R.string.dashboard)
                navView.setCheckedItem(R.id.navigationDashboard)
                bottomNavView.selectedItemId = R.id.navigationDashboard
            }
            1 -> {
                Log.d("IGFlexin_app", "Selected accounts")
                toolbar.title = getString(R.string.accounts)
                navView.setCheckedItem(R.id.navigationInstagramAccounts)
                bottomNavView.selectedItemId = R.id.navigationInstagramAccounts
            }
            2 -> {
                Log.d("IGFlexin_app", "Selected subscription")
                toolbar.title = getString(R.string.subscription)
                navView.setCheckedItem(R.id.navigationSubscriptionManagement)
                bottomNavView.selectedItemId = R.id.navigationSubscriptionManagement
            }
        }

        val currentFragment = childFragmentManager.fragments[viewPager.currentItem]

        if (currentFragment is OnSelectedListener) {
            currentFragment.onSelected()
        }
    }

    override fun onBackPressed(): Boolean {

        if (viewModel.loading)
            return true

        val currentFragment = childFragmentManager.fragments[viewPager.currentItem]

        return if (currentFragment is OnBackPressedListener && currentFragment.onBackPressed()) {
            true
        } else {
            if (viewPager.currentItem != 0) {
                viewPager.setCurrentItem(viewPager.currentItem - 1,true)
                true
            }else {
                false
            }
        }
    }
}
