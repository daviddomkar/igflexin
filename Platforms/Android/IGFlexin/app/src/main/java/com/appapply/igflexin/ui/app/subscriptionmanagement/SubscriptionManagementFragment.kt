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
import com.appapply.igflexin.common.*
import com.appapply.igflexin.events.EventObserver
import com.appapply.igflexin.ui.app.AppViewModel
import kotlinx.android.synthetic.main.subscription_management_fragment.*
import org.koin.androidx.viewmodel.ext.android.sharedViewModel
import java.lang.Exception

class SubscriptionManagementFragment : Fragment(), OnBackPressedListener {

    private val viewModel: SubscriptionManagementViewModel by sharedViewModel()
    private val appViewModel: AppViewModel by sharedViewModel()

    // This will crash the app, used for testing
    /*
    init {
        requireContext()
    }
    */

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.subscription_management_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        val adapter = SubscriptionManagementViewPageAdapter(requireContext(), childFragmentManager)

        viewPager.adapter = adapter
        viewPager.offscreenPageLimit = adapter.count - 1

        tabs.setupWithViewPager(viewPager)

        retryButton.setOnClickListener {
            viewModel.getSubscriptionBundles()
        }

        viewModel.subscriptionLiveData.observe(this, Observer {
            if (it.status == StatusCode.SUCCESS) {
                val data = it.data!!

                if (data.subscriptionID != viewModel.lastSubscription) {
                    viewModel.lastSubscription = "none"
                    appViewModel.showProgressBar(false)
                }
            }
        })

        viewModel.subscriptionBundlesLiveData.observe(this, Observer {
            val res = when (it.status) {
                StatusCode.ERROR -> { R.string.error_loading_subscriptions }
                StatusCode.NETWORK_ERROR -> R.string.error_loading_subscriptions_check_your_internet_connection
                BillingStatusCode.BILLING_UNAVAILABLE -> R.string.service_unavailable
                BillingStatusCode.FEATURE_NOT_SUPPORTED -> R.string.feature_not_supported
                BillingStatusCode.SERVICE_DISCONNECTED -> R.string.error_loading_subscriptions_service_disconnected
                else -> {
                    viewModel.showErrorLayout(false)

                    if (it.data != null  && it.data.size < 12) {
                        viewModel.getSubscriptionBundles()
                        return@Observer
                    }

                    return@Observer
                }
            }

            errorTextView.text = getString(res)

            viewModel.showErrorLayout(true)
        })

        viewModel.showErrorLayoutLiveData.observe(this, Observer {
            if (it) {
                errorLayout.visibility = View.VISIBLE
                errorLayout.animate().setDuration(200).alpha(1.0f).start()
            } else {
                errorLayout.animate().setDuration(200).alpha(0.0f).withEndAction {
                    try {
                        errorLayout.visibility = View.GONE
                    } catch (e: Exception) { }
                }.start()
            }
        })

        viewModel.subscriptionUpgradeDowngradeLiveData.observe(this, Observer {
            when(it) {
                StatusCode.ERROR -> showErrorDialog(getString(R.string.error_loading_subscriptions))
                StatusCode.NETWORK_ERROR -> showErrorDialog(getString(R.string.error_loading_subscriptions_check_your_internet_connection))
                BillingStatusCode.BILLING_UNAVAILABLE -> showErrorDialog(getString(R.string.service_unavailable))
                BillingStatusCode.FEATURE_NOT_SUPPORTED -> showErrorDialog(getString(R.string.feature_not_supported))
                BillingStatusCode.SERVICE_DISCONNECTED -> showErrorDialog(getString(R.string.error_loading_subscriptions_service_disconnected))
            }
        })

        viewModel.subscriptionPurchaseResultLiveData.observe(this, EventObserver {
            Log.d("IGFlexin_subscription", "HAHAHA Purchase result")
            Log.d("IGFlexin_subscription", getStringStatusCode(it.status))

            when (it.status) {
                StatusCode.SUCCESS -> {
                    val purchaseList = it.data!!

                    for (purchase in purchaseList) {
                        viewModel.verifySubscription(purchase.sku, purchase.purchaseToken)
                    }
                }
                StatusCode.ERROR -> {
                    showErrorDialog(getString(R.string.wrong_gp_account_error))
                }
            }
        })

        viewModel.subscriptionVerifiedLiveData.observe(this, Observer {
            when (it) {
                StatusCode.PENDING -> {
                    appViewModel.showProgressBar(true)
                }
                StatusCode.ERROR -> {
                    appViewModel.showProgressBar(false)
                }
            }
        })
    }

    private fun showErrorDialog(message: String) {
        val dialogBuilder = AlertDialog.Builder(requireContext())

        dialogBuilder.setTitle(getString(R.string.error))
        dialogBuilder.setMessage(message)
        dialogBuilder.setPositiveButton(getString(R.string.ok)) { dialogInterface, _ ->
            dialogInterface.cancel()
        }

        dialogBuilder.setCancelable(false)

        val dialog = dialogBuilder.create()
        dialog.show()
    }

    override fun onBackPressed(): Boolean {
        return if (viewPager.currentItem != 0) {
            viewPager.setCurrentItem(viewPager.currentItem - 1,true)
            true
        } else {
            false
        }
    }
}