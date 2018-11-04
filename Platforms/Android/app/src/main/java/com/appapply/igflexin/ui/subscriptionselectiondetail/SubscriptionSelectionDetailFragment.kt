package com.appapply.igflexin.ui.subscriptionselectiondetail

import android.os.Bundle
import android.util.Log.d
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.appcompat.app.AlertDialog
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.Observer
import androidx.lifecycle.Transformations
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import com.android.billingclient.api.Purchase
import com.appapply.igflexin.MainActivityViewModel

import com.appapply.igflexin.R
import com.appapply.igflexin.billing.Product
import com.appapply.igflexin.codes.BillingStatusCode
import com.appapply.igflexin.codes.StatusCode
import com.appapply.igflexin.events.EventObserver
import com.appapply.igflexin.pojo.Subscription
import kotlinx.android.synthetic.main.subscription_selection_detail_fragment.*
import org.koin.androidx.viewmodel.ext.android.sharedViewModel
import org.koin.androidx.viewmodel.ext.android.viewModel

class SubscriptionSelectionDetailFragment : Fragment() {

    private val subscriptionSelectionDetailViewModel: SubscriptionSelectionDetailViewModel by viewModel()
    private val mainActivityViewModel: MainActivityViewModel by sharedViewModel()

    private var loadedOnce = false

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.subscription_selection_detail_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        mainActivityViewModel.disableBackNavigation(false)

        val subscriptionID = SubscriptionSelectionDetailFragmentArgs.fromBundle(arguments).subscriptionID

        val viewManager = LinearLayoutManager(requireContext())
        val viewAdapter = SubscriptionSelectionDetailAdapter {
            subscriptionSelectionDetailViewModel.initiateSubscriptionPurchaseFlow(requireActivity(), it)
        }

        subscriptionDetailsRecyclerView.apply {
            layoutManager = viewManager
            adapter = viewAdapter
        }

        backImageButton.setOnClickListener {
            findNavController().popBackStack(R.id.subscriptionSelectionFragment, false)
        }

        var subscriptionList = listOf<String>()

        when (subscriptionID) {
            Product.WEEKLY_BASIC_SUBSCRIPTION -> {
                subscriptionList = listOf(Product.WEEKLY_BASIC_SUBSCRIPTION, Product.WEEKLY_STANDARD_SUBSCRIPTION, Product.WEEKLY_BUSINESS_SUBSCRIPTION, Product.WEEKLY_BUSINESS_PRO_SUBSCRIPTION)
                titleTextView.text = getString(R.string.choose_your_weekly_bundle)
            }
            Product.MONTHLY_BASIC_SUBSCRIPTION -> {
                subscriptionList = listOf(Product.MONTHLY_BASIC_SUBSCRIPTION, Product.MONTHLY_STANDARD_SUBSCRIPTION, Product.MONTHLY_BUSINESS_SUBSCRIPTION, Product.MONTHLY_BUSINESS_PRO_SUBSCRIPTION)
                titleTextView.text = getString(R.string.choose_your_monthly_bundle)
            }
            Product.QUARTERLY_BASIC_SUBSCRIPTION -> {
                subscriptionList = listOf(Product.QUARTERLY_BASIC_SUBSCRIPTION, Product.QUARTERLY_STANDARD_SUBSCRIPTION, Product.QUARTERLY_BUSINESS_SUBSCRIPTION, Product.QUARTERLY_BUSINESS_PRO_SUBSCRIPTION)
                titleTextView.text = getString(R.string.choose_your_quarterly_bundle)

            }
        }

        subscriptionSelectionDetailViewModel.setSubscriptionDetailsLiveDataInput(subscriptionList)

        subscriptionSelectionDetailViewModel.getSubscriptionDetailsLiveData().observe(this, Observer { list ->
            if (!loadedOnce) {
                showLoading(false)
                loadedOnce = true
            }

            subscriptionDetailsProgressBar.visibility = View.GONE

            val sortedList = list.sortedWith(compareBy { getSubscriptionIndex(it.id ) })

            for (subscription in sortedList) {

                subscription.title = getSubscriptionTitle(subscription)
                subscription.description = getSubscriptionDescription(subscription)

            }

            viewAdapter.setList(sortedList)
        })


        subscriptionSelectionDetailViewModel.getSubscriptionPurchasesLiveData().observe(this, EventObserver { list ->
            showLoading(true)
            for (purchase in list) {
                subscriptionSelectionDetailViewModel.verifySubscriptionPurchase(purchase.sku, purchase.purchaseToken)
            }
        })

        subscriptionSelectionDetailViewModel.getSubscriptionVerifiedLiveData().observe(this, Observer {
            when(it) {
                StatusCode.PENDING -> {
                    showLoading(true)
                }
                StatusCode.SUCCESS -> {
                    d("IGFlexin", "Verified")
                }
                StatusCode.ERROR -> {
                    showLoading(false)
                    showErrorDialog("The server could not verify your purchase.")
                }
            }
        })

        subscriptionSelectionDetailViewModel.getSubscriptionStatusLiveData().observe(this, Observer {
            when(it) {
                StatusCode.ERROR -> showErrorDialog("Error loading subscriptions.")
                StatusCode.NETWORK_ERROR -> showErrorDialog("Error loading subscriptions, check your internet connection.")
                BillingStatusCode.BILLING_UNAVAILABLE -> showErrorDialog("Service is unavailable.")
                BillingStatusCode.FEATURE_NOT_SUPPORTED -> showErrorDialog("Feature is not supported.")
                BillingStatusCode.SERVICE_DISCONNECTED -> showErrorDialog("Error loading subscriptions, service is disconnected.")
                BillingStatusCode.ITEM_ALREADY_OWNED -> {
                    showLoading(true)
                    subscriptionSelectionDetailViewModel.validateSubscriptions()
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

    private fun showLoading(show: Boolean) {
        mainActivityViewModel.showProgressBar(show, true)
        mainActivityViewModel.disableBackNavigation(show)
    }

    private fun getSubscriptionIndex(id: String): Int {
        when (id) {
            Product.WEEKLY_BASIC_SUBSCRIPTION           -> return 0
            Product.MONTHLY_BASIC_SUBSCRIPTION          -> return 0
            Product.QUARTERLY_BASIC_SUBSCRIPTION        -> return 0
            Product.WEEKLY_STANDARD_SUBSCRIPTION        -> return 1
            Product.MONTHLY_STANDARD_SUBSCRIPTION       -> return 1
            Product.QUARTERLY_STANDARD_SUBSCRIPTION     -> return 1
            Product.WEEKLY_BUSINESS_SUBSCRIPTION        -> return 2
            Product.MONTHLY_BUSINESS_SUBSCRIPTION       -> return 2
            Product.QUARTERLY_BUSINESS_SUBSCRIPTION     -> return 2
            Product.WEEKLY_BUSINESS_PRO_SUBSCRIPTION    -> return 3
            Product.MONTHLY_BUSINESS_PRO_SUBSCRIPTION   -> return 3
            Product.QUARTERLY_BUSINESS_PRO_SUBSCRIPTION -> return 3
        }

        return 0
    }

    private fun getSubscriptionTitle(subscription: Subscription): String {
        when (subscription.id) {
            Product.WEEKLY_BASIC_SUBSCRIPTION,
            Product.MONTHLY_BASIC_SUBSCRIPTION,
            Product.QUARTERLY_BASIC_SUBSCRIPTION        -> return getString(R.string.basic)
            Product.WEEKLY_STANDARD_SUBSCRIPTION,
            Product.MONTHLY_STANDARD_SUBSCRIPTION,
            Product.QUARTERLY_STANDARD_SUBSCRIPTION     -> return getString(R.string.standard)
            Product.WEEKLY_BUSINESS_SUBSCRIPTION,
            Product.MONTHLY_BUSINESS_SUBSCRIPTION,
            Product.QUARTERLY_BUSINESS_SUBSCRIPTION     -> return getString(R.string.business)
            Product.WEEKLY_BUSINESS_PRO_SUBSCRIPTION,
            Product.MONTHLY_BUSINESS_PRO_SUBSCRIPTION,
            Product.QUARTERLY_BUSINESS_PRO_SUBSCRIPTION -> return getString(R.string.business_pro)
        }

        return subscription.id
    }

    private fun getSubscriptionDescription(subscription: Subscription): String {
        when (subscription.id) {
            Product.WEEKLY_BASIC_SUBSCRIPTION,
            Product.MONTHLY_BASIC_SUBSCRIPTION,
            Product.QUARTERLY_BASIC_SUBSCRIPTION        -> return subscription.price + " - " + getString(R.string.limited_to_one_ig_acc)
            Product.WEEKLY_STANDARD_SUBSCRIPTION,
            Product.MONTHLY_STANDARD_SUBSCRIPTION,
            Product.QUARTERLY_STANDARD_SUBSCRIPTION     -> return subscription.price + " - " + getString(R.string.up_to_three_ig_accs)
            Product.WEEKLY_BUSINESS_SUBSCRIPTION,
            Product.MONTHLY_BUSINESS_SUBSCRIPTION,
            Product.QUARTERLY_BUSINESS_SUBSCRIPTION     -> return subscription.price + " - " + getString(R.string.up_to_six_ig_accs)
            Product.WEEKLY_BUSINESS_PRO_SUBSCRIPTION,
            Product.MONTHLY_BUSINESS_PRO_SUBSCRIPTION,
            Product.QUARTERLY_BUSINESS_PRO_SUBSCRIPTION -> return subscription.price + " - " + getString(R.string.unlimited_num_of_ig_accs)
        }

        return subscription.id
    }
}
