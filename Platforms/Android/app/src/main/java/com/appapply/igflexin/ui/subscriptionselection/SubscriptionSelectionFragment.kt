package com.appapply.igflexin.ui.subscriptionselection

import android.os.Bundle
import android.os.Message
import android.util.Log.d
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.appcompat.app.AlertDialog
import androidx.lifecycle.Observer
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import com.appapply.igflexin.MainActivityViewModel
import com.appapply.igflexin.R
import com.appapply.igflexin.billing.Product
import com.appapply.igflexin.codes.BillingStatusCode
import com.appapply.igflexin.codes.StatusCode
import com.appapply.igflexin.pojo.Subscription
import kotlinx.android.synthetic.main.subscription_selection_fragment.*
import org.koin.androidx.viewmodel.ext.android.sharedViewModel
import org.koin.androidx.viewmodel.ext.android.viewModel

class SubscriptionSelectionFragment : Fragment() {

    private val mainActivityViewModel: MainActivityViewModel by sharedViewModel()
    private val subscriptionSelectionViewModel: SubscriptionSelectionViewModel by viewModel()

    private lateinit var viewAdapter: SubscriptionSelectionAdapter

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.subscription_selection_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        val viewManager = LinearLayoutManager(requireContext())
        viewAdapter = SubscriptionSelectionAdapter(findNavController())

        subscriptionsRecyclerView.apply {
            layoutManager = viewManager
            adapter = viewAdapter
        }

        mainActivityViewModel.disableBackNavigation(true)

        getSubscriptions()

        subscriptionSelectionViewModel.getSubscriptionStatusLiveData().observe(this, Observer {
            when(it) {
                StatusCode.ERROR -> showErrorDialog("Error loading subscriptions.")
                StatusCode.NETWORK_ERROR -> showErrorDialog("Error loading subscriptions, check your internet connection.")
                BillingStatusCode.BILLING_UNAVAILABLE -> showErrorDialog("Service is unavailable.")
                BillingStatusCode.FEATURE_NOT_SUPPORTED -> showErrorDialog("Feature is not supported.")
                BillingStatusCode.SERVICE_DISCONNECTED -> showErrorDialog("Error loading subscriptions, service is disconnected.")
            }
        })
    }

    private fun showErrorDialog(message: String) {
        val dialogBuilder = AlertDialog.Builder(requireContext())

        dialogBuilder.setTitle(getString(R.string.error))
        dialogBuilder.setMessage(message)
        dialogBuilder.setPositiveButton(getString(R.string.retry)) { dialogInterface, _ ->
            dialogInterface.cancel()
            getSubscriptions()
        }

        dialogBuilder.setCancelable(false)

        val dialog = dialogBuilder.create()
        dialog.show()
    }

    private fun getSubscriptions() {
        subscriptionSelectionViewModel.setSubscriptionDetailsLiveDataInput(listOf(Product.WEEKLY_BASIC_SUBSCRIPTION, Product.MONTHLY_BASIC_SUBSCRIPTION, Product.QUARTERLY_BASIC_SUBSCRIPTION))

        subscriptionSelectionViewModel.getSubscriptionDetailsLiveData().observe(this, Observer { list ->
            mainActivityViewModel.showProgressBar(false, false)
            subscriptionsProgressBar.visibility = View.GONE

            val sortedList = list.sortedWith(compareBy { getSubscriptionIndex(it.id ) })

            for (subscription in sortedList) {

                subscription.title = getSubscriptionTitle(subscription)
                subscription.description = getSubscriptionDescription(subscription)

            }

            viewAdapter.setList(sortedList)
        })
    }

    private fun getSubscriptionIndex(id: String): Int {
        when (id) {
            Product.WEEKLY_BASIC_SUBSCRIPTION    -> return 0
            Product.MONTHLY_BASIC_SUBSCRIPTION   -> return 1
            Product.QUARTERLY_BASIC_SUBSCRIPTION -> return 2
        }

        return 0
    }

    private fun getSubscriptionTitle(subscription: Subscription): String {
        when (subscription.id) {
            Product.WEEKLY_BASIC_SUBSCRIPTION    -> return getString(R.string.weekly)
            Product.MONTHLY_BASIC_SUBSCRIPTION   -> return getString(R.string.monthly)
            Product.QUARTERLY_BASIC_SUBSCRIPTION -> return getString(R.string.quarterly_best_variant)
        }

        return subscription.id
    }

    private fun getSubscriptionDescription(subscription: Subscription): String {
        when (subscription.id) {
            Product.WEEKLY_BASIC_SUBSCRIPTION    -> return getString(R.string.starting_at) + " " + subscription.price + " " + getString(R.string.per_week) + "."
            Product.MONTHLY_BASIC_SUBSCRIPTION   -> return getString(R.string.starting_at) + " " + subscription.price + " " + getString(R.string.per_month) + "."
            Product.QUARTERLY_BASIC_SUBSCRIPTION -> return getString(R.string.starting_at) + " " + subscription.price + " " + getString(R.string.per_quarter_of_a_year) + "."
        }

        return subscription.id
    }
}
