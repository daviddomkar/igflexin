package com.appapply.igflexin.ui.subscription

import android.os.Bundle
import android.util.Log
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.appcompat.app.AlertDialog
import androidx.lifecycle.Observer
import androidx.navigation.fragment.NavHostFragment
import androidx.navigation.fragment.findNavController

import com.appapply.igflexin.R
import com.appapply.igflexin.common.BillingStatusCode
import com.appapply.igflexin.common.OnBackPressedFinishListener
import com.appapply.igflexin.common.StatusCode
import com.appapply.igflexin.events.EventObserver
import kotlinx.android.synthetic.main.auth_fragment.*
import org.koin.androidx.viewmodel.ext.android.viewModel

class SubscriptionFragment : Fragment(), OnBackPressedFinishListener {

    private val viewModel: SubscriptionViewModel by viewModel()

    private var verifyDialogDisplayed = false
    private var verifyDialog: AlertDialog? = null

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.subscription_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        viewModel.subscriptionLiveData.observe(this, Observer { resource ->
            when (resource.status) {
                StatusCode.SUCCESS -> {
                    if (resource.data!!.verified) {
                        viewModel.subscriptionPurchaseLiveData.removeObservers(this)
                        viewModel.resetPurchaseLiveData()

                        verifyDialog?.dismiss()

                        findNavController().popBackStack()
                    } else {
                        viewModel.showProgressBar(false)
                        if (!viewModel.dialogCanceled) {
                            verifySubscriptionDialog(resource.data.subscriptionID, resource.data.purchaseToken)
                        }
                    }
                }
                StatusCode.ERROR -> {
                    viewModel.showProgressBar(false)
                }
            }
        })

        viewModel.subscriptionPurchaseLiveData.observe(this, Observer {
            when(it) {
                StatusCode.ERROR -> showErrorDialog(getString(R.string.error_loading_subscriptions))
                StatusCode.NETWORK_ERROR -> showErrorDialog(getString(R.string.error_loading_subscriptions_check_your_internet_connection))
                BillingStatusCode.BILLING_UNAVAILABLE -> showErrorDialog(getString(R.string.service_unavailable))
                BillingStatusCode.FEATURE_NOT_SUPPORTED -> showErrorDialog(getString(R.string.feature_not_supported))
                BillingStatusCode.SERVICE_DISCONNECTED -> showErrorDialog(getString(R.string.error_loading_subscriptions_service_disconnected))
            }
        })

        viewModel.subscriptionPurchaseResultLiveData.observe(this, EventObserver {
            Log.d("IGFlexin", "Hehe")
            when (it.status) {
                StatusCode.SUCCESS -> {
                    val purchaseList = it.data!!

                    for (purchase in purchaseList) {
                        viewModel.verifySubscription(purchase.sku, purchase.purchaseToken)
                    }
                }
                BillingStatusCode.ITEM_ALREADY_OWNED -> {
                    showSignInWithAnotherAccountDialog()
                }
            }
        })

        viewModel.showProgressBarLiveData.observe(this, Observer {
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

        viewModel.subscriptionVerifiedLiveData.observe(this, Observer {
            when (it) {
                StatusCode.PENDING -> {
                    viewModel.showProgressBar(true)
                }
                StatusCode.ERROR -> {
                    viewModel.showProgressBar(false)
                    if (!viewModel.dialogCanceled) {
                        viewModel.subscriptionLiveData.value?.data?.subscriptionID?.let { subscriptionID ->
                            viewModel.subscriptionLiveData.value?.data?.purchaseToken?.let { purchaseToken ->
                                verifySubscriptionDialog(
                                    subscriptionID, purchaseToken
                                )
                            }
                        }
                    }
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

    private fun showSignInWithAnotherAccountDialog() {
        val dialogBuilder = AlertDialog.Builder(requireContext())

        dialogBuilder.setTitle(getString(R.string.error))
        dialogBuilder.setMessage("This subscription is already purchased for another IGFlexin account. If it´s not restart the app and try it again later.")
        dialogBuilder.setPositiveButton("Log out") { dialogInterface, _ ->
            dialogInterface.cancel()
            viewModel.logOut()
            viewModel.subscriptionPurchaseLiveData.removeObservers(this)
            viewModel.resetPurchaseLiveData()
            findNavController().popBackStack()
        }

        dialogBuilder.setCancelable(true)

        val dialog = dialogBuilder.create()
        dialog.show()
    }

    private fun verifySubscriptionDialog(id: String, token: String) {
        if (verifyDialogDisplayed) return

        val dialogBuilder = AlertDialog.Builder(requireContext())

        dialogBuilder.setTitle(getString(R.string.error))
        dialogBuilder.setMessage("Server could not verify your subscription.")
        dialogBuilder.setPositiveButton("Retry") { dialogInterface, _ ->
            verifyDialogDisplayed = false
            verifyDialog = null
            dialogInterface.cancel()
            viewModel.verifySubscription(id, token)
        }
        dialogBuilder.setNegativeButton(getString(R.string.cancel)) { dialogInterface, _ ->
            verifyDialogDisplayed = false
            viewModel.dialogCanceled = true
            dialogInterface.cancel()
        }

        dialogBuilder.setCancelable(false)

        verifyDialog = dialogBuilder.create()
        verifyDialog?.show()
        verifyDialogDisplayed = true
    }

    override fun onBackPressed(): Boolean {
        if (viewModel.loading) return true

        val currentFragment = childFragmentManager.fragments[0]

        return if (!(currentFragment is NavHostFragment && !currentFragment.navController.popBackStack())) {
            true
        } else {
            verifyDialog?.dismiss()
            viewModel.subscriptionPurchaseLiveData.removeObservers(this)
            viewModel.resetPurchaseLiveData()
            false
        }
    }
}
