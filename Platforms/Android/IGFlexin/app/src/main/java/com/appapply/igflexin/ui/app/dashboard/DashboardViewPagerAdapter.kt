package com.appapply.igflexin.ui.app.dashboard

import android.content.Context
import android.os.Bundle
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentPagerAdapter
import com.appapply.igflexin.common.StatsPeriod
import com.appapply.igflexin.ui.app.dashboard.dashboardtab.DashboardTabFragment

class DashboardViewPagerAdapter(private val context: Context, private val fragmentManager: FragmentManager) : FragmentPagerAdapter(fragmentManager) {

    override fun getItem(position: Int): Fragment {
        return when (position) {
            0 -> {
                val fragment = DashboardTabFragment()

                val args = Bundle()
                args.putInt("period", StatsPeriod.DAY)
                fragment.arguments = args

                fragment
            }
            1 -> {
                val fragment = DashboardTabFragment()

                val args = Bundle()
                args.putInt("period", StatsPeriod.WEEK)
                fragment.arguments = args

                fragment
            }
            2 -> {
                val fragment = DashboardTabFragment()

                val args = Bundle()
                args.putInt("period", StatsPeriod.MONTH)
                fragment.arguments = args

                fragment
            }
            else -> {
                val fragment = DashboardTabFragment()

                val args = Bundle()
                args.putInt("period", StatsPeriod.DAY)
                fragment.arguments = args

                fragment
            }
        }
    }

    override fun getPageTitle(position: Int): CharSequence? {
        return when (position) {
            0 -> "DAY"
            1 -> "WEEK"
            2 -> "MONTH"
            else -> "DAY"
        }
    }

    override fun getCount(): Int {
        return 3
    }
}