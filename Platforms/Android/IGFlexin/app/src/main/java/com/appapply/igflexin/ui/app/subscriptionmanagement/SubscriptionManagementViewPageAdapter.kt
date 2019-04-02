package com.appapply.igflexin.ui.app.subscriptionmanagement

import android.content.Context
import android.os.Bundle
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentPagerAdapter
import com.appapply.igflexin.R
import com.appapply.igflexin.billing.Product
import com.appapply.igflexin.ui.app.subscriptionmanagement.subscriptiontab.SubscriptionTabFragment

class SubscriptionManagementViewPageAdapter(private val context: Context, private val fragmentManager: FragmentManager) : FragmentPagerAdapter(fragmentManager) {

    override fun getItem(position: Int): Fragment {
        return when (position) {
            0 -> {
                val fragment = SubscriptionTabFragment()

                val args = Bundle()
                args.putString("period", Product.WEEKLY_BASIC_SUBSCRIPTION)
                fragment.arguments = args

                fragment
            }
            1 -> {
                val fragment = SubscriptionTabFragment()

                val args = Bundle()
                args.putString("period", Product.MONTHLY_BASIC_SUBSCRIPTION)
                fragment.arguments = args

                fragment
            }
            2 -> {
                val fragment = SubscriptionTabFragment()

                val args = Bundle()
                args.putString("period", Product.QUARTERLY_BASIC_SUBSCRIPTION)
                fragment.arguments = args

                fragment
            }
            else -> {
                val fragment = SubscriptionTabFragment()

                val args = Bundle()
                args.putString("period", Product.WEEKLY_BASIC_SUBSCRIPTION)
                fragment.arguments = args

                fragment
            }
        }
    }

    override fun getPageTitle(position: Int): CharSequence? {
        return when (position) {
            0 -> context.getString(R.string.weekly)
            1 -> context.getString(R.string.monthly)
            2 -> context.getString(R.string.quarterly)
            else -> context.getString(R.string.weekly)
        }
    }

    override fun getCount(): Int {
        return 3
    }
}