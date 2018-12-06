package com.appapply.igflexin.ui.app.subscriptionmanagement

import android.os.Bundle
import android.util.Log
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.appcompat.app.AlertDialog
import androidx.lifecycle.Observer
import com.appapply.igflexin.R
import com.appapply.igflexin.billing.Product
import com.appapply.igflexin.common.BillingStatusCode
import com.appapply.igflexin.common.OnBackPressedListener
import com.appapply.igflexin.common.OnSelectedListener
import com.appapply.igflexin.common.StatusCode
import com.appapply.igflexin.model.SubscriptionBundle
import kotlinx.android.synthetic.main.period_fragment.*
import kotlinx.android.synthetic.main.subscription_management_fragment.*
import org.koin.androidx.viewmodel.ext.android.sharedViewModel
import org.koin.androidx.viewmodel.ext.android.viewModel

class SubscriptionManagementFragment : Fragment(), OnBackPressedListener, OnSelectedListener {

    private val viewModel: SubscriptionManagementViewModel by viewModel()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.subscription_management_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        val adapter = SubscriptionManagementViewPageAdapter(requireContext(), childFragmentManager)

        viewPager.adapter = adapter
        viewPager.offscreenPageLimit = adapter.count - 1

        tabs.setupWithViewPager(viewPager)

        viewModel.subscriptionBundlesLiveData.observe(this, Observer {

            val res = when (it.status) {
                StatusCode.ERROR -> R.string.error_loading_subscriptions
                StatusCode.NETWORK_ERROR -> R.string.error_loading_subscriptions_check_your_internet_connection
                BillingStatusCode.BILLING_UNAVAILABLE -> R.string.service_unavailable
                BillingStatusCode.FEATURE_NOT_SUPPORTED -> R.string.feature_not_supported
                BillingStatusCode.SERVICE_DISCONNECTED -> R.string.error_loading_subscriptions_service_disconnected
                else -> {
                    return@Observer
                }
            }

            showErrorDialog(getString(res))
            viewModel.error = true
            viewModel.errorMessage = res
        })
    }

    private fun showErrorDialog(message: String) {
        val dialogBuilder = AlertDialog.Builder(requireContext())

        dialogBuilder.setTitle(getString(R.string.error))
        dialogBuilder.setMessage(message)
        dialogBuilder.setPositiveButton(getString(R.string.retry)) { dialogInterface, _ ->
            dialogInterface.cancel()
            viewModel.getSubscriptionBundles()
            viewModel.error = false
        }

        dialogBuilder.setCancelable(false)

        val dialog = dialogBuilder.create()
        dialog.show()
    }

    override fun onSelected() {
        if (viewModel.error) {
            showErrorDialog(getString(viewModel.errorMessage))
        }
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
