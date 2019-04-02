package com.appapply.igflexin.ui.app

import android.content.Context
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentPagerAdapter
import com.appapply.igflexin.R
import com.appapply.igflexin.ui.app.dashboard.DashboardFragment
import com.appapply.igflexin.ui.app.instagramaccounts.InstagramAccountsFragment
import com.appapply.igflexin.ui.app.subscriptionmanagement.SubscriptionManagementFragment

class AppViewPagerAdapter(private val context: Context,  private val fragmentManager: FragmentManager) : FragmentPagerAdapter(fragmentManager) {

    override fun getItem(position: Int): Fragment {
        return when (position) {
            0 -> DashboardFragment()
            1 -> InstagramAccountsFragment()
            2 -> SubscriptionManagementFragment()
            else -> DashboardFragment()
        }
    }

    override fun getCount(): Int {
        return 3
    }

    override fun getPageTitle(position: Int): CharSequence? {
        return when (position) {
            0 -> context.getString(R.string.dashboard)
            1 -> context.getString(R.string.accounts)
            2 -> context.getString(R.string.subscription)
            else -> context.getString(R.string.dashboard)
        }
    }
}