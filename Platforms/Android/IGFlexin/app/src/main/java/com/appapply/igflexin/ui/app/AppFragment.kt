package com.appapply.igflexin.ui.app

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
import androidx.lifecycle.Observer
import androidx.navigation.fragment.findNavController
import androidx.viewpager.widget.ViewPager

import com.appapply.igflexin.R
import com.appapply.igflexin.common.OnBackPressedFinishListener
import com.appapply.igflexin.common.OnBackPressedListener
import com.appapply.igflexin.common.StatusCode
import com.google.android.material.bottomnavigation.BottomNavigationView
import kotlinx.android.synthetic.main.app_fragment.*
import org.koin.androidx.viewmodel.ext.android.viewModel

class AppFragment : Fragment(), OnBackPressedFinishListener, BottomNavigationView.OnNavigationItemSelectedListener, ViewPager.OnPageChangeListener {

    private val viewModel: AppViewModel by viewModel()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.app_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        (requireActivity() as AppCompatActivity).setSupportActionBar(toolbar)

        val adapter = AppViewPagerAdapter(childFragmentManager)

        viewPager.adapter = adapter
        viewPager.offscreenPageLimit = adapter.count - 1

        viewPager.addOnPageChangeListener(this)

        bottomNavView.setOnNavigationItemSelectedListener(this)

        bindNavigationDrawer()
        initTitle()

        viewModel.subscriptionLiveData.observe(this, Observer {
            when (it.status) {
                StatusCode.SUCCESS -> {
                    if (!it.data!!.verified) {
                        findNavController().popBackStack()
                    }
                }
                StatusCode.ERROR -> {

                }
            }
        })

        viewModel.userLiveData.observe(this, Observer {
            if (it.status == StatusCode.ERROR) {
                findNavController().popBackStack()
            }
        })
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

    private fun initTitle() {
        toolbar.post { toolbar.title = bottomNavView.menu.getItem(0).title }
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
    }

    override fun onBackPressed(): Boolean {

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
