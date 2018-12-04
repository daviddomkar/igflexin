package com.appapply.igflexin.ui.app.subscriptionmanagement

import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.appapply.igflexin.R
import com.appapply.igflexin.common.OnBackPressedListener
import kotlinx.android.synthetic.main.subscription_management_fragment.*
import org.koin.androidx.viewmodel.ext.android.viewModel

class SubscriptionManagementFragment : Fragment(), OnBackPressedListener {

    private val viewModel: SubscriptionManagementViewModel by viewModel()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.subscription_management_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        val adapter = SubscriptionManagementViewPageAdapter(requireContext(), childFragmentManager)

        viewPager.adapter = adapter
        viewPager.offscreenPageLimit = adapter.count - 1
    }

    override fun onBackPressed(): Boolean {
        return if (viewPager.currentItem != 0) {
            viewPager.setCurrentItem(viewPager.currentItem - 1,true)
            true
        }else {
            false
        }
    }
}
