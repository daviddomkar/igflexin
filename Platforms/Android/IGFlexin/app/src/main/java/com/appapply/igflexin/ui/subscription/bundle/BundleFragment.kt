package com.appapply.igflexin.ui.subscription.bundle

import android.os.Bundle
import android.util.Log
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.appcompat.app.AlertDialog
import androidx.lifecycle.Observer
import androidx.lifecycle.Transformations
import androidx.recyclerview.widget.LinearLayoutManager
import com.appapply.igflexin.R
import com.appapply.igflexin.billing.Product
import com.appapply.igflexin.common.BillingStatusCode
import com.appapply.igflexin.common.StatusCode
import com.appapply.igflexin.model.SubscriptionBundle
import kotlinx.android.synthetic.main.period_fragment.*
import org.koin.androidx.viewmodel.ext.android.viewModel

class BundleFragment : Fragment() {

    private val viewModel: BundleViewModel by viewModel()
    private lateinit var viewAdapter: BundleAdapter

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.bundle_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        if (arguments != null) {
            viewModel.setPeriod(BundleFragmentArgs.fromBundle(arguments!!).period)

            when (BundleFragmentArgs.fromBundle(arguments!!).period) {
                Product.WEEKLY_BASIC_SUBSCRIPTION -> usernameTextView.text = getString(R.string.choose_your_weekly_bundle)
                Product.MONTHLY_BASIC_SUBSCRIPTION -> usernameTextView.text = getString(R.string.choose_your_monthly_bundle)
                Product.QUARTERLY_BASIC_SUBSCRIPTION -> usernameTextView.text = getString(R.string.choose_your_quarterly_bundle)
            }
        }

        val viewManager = object : LinearLayoutManager(requireContext()) {
            override fun canScrollVertically(): Boolean {
                return false
            }
        }

        viewAdapter = BundleAdapter(requireContext()) {
            Log.d("IGFlexin_subscription", "Ready to purchase $it")
            viewModel.purchaseSubscription(requireActivity(), it)
        }

        subscriptionsRecyclerView.setHasFixedSize(true)
        subscriptionsRecyclerView.isNestedScrollingEnabled = false

        subscriptionsRecyclerView.apply {
            layoutManager = viewManager
            adapter = viewAdapter
        }

        Transformations.switchMap(viewModel.subscriptionLiveData) {
            if (it.status == StatusCode.SUCCESS) {
                val data = it.data!!

                viewAdapter.setID(data.subscriptionID)
            }
            viewModel.subscriptionBundlesLiveData
        }.observe(this, Observer {
            when (it.status) {
                StatusCode.PENDING -> {
                    viewAdapter.setList(listOf())
                    progressBar.visibility = View.VISIBLE
                }
                StatusCode.SUCCESS -> {
                    val rawList = it.data!!

                    val list = ArrayList<SubscriptionBundle>()

                    for (rawBundle in rawList) {
                        list.add(SubscriptionBundle(rawBundle.id, getString(rawBundle.title), rawBundle.price, getString(rawBundle.description), getString(rawBundle.restriction)))
                    }

                    viewAdapter.setList(list)

                    progressBar.visibility = View.GONE
                }

                StatusCode.ERROR -> showErrorDialog(getString(R.string.error_loading_subscriptions))
                StatusCode.NETWORK_ERROR -> showErrorDialog(getString(R.string.error_loading_subscriptions_check_your_internet_connection))
                BillingStatusCode.BILLING_UNAVAILABLE -> showErrorDialog(getString(R.string.service_unavailable))
                BillingStatusCode.FEATURE_NOT_SUPPORTED -> showErrorDialog(getString(R.string.feature_not_supported))
                BillingStatusCode.SERVICE_DISCONNECTED -> showErrorDialog(getString(R.string.error_loading_subscriptions_service_disconnected))
            }
        })
    }

    private fun showErrorDialog(message: String) {
        val dialogBuilder = AlertDialog.Builder(requireContext())

        dialogBuilder.setTitle(getString(R.string.error))
        dialogBuilder.setMessage(message)
        dialogBuilder.setPositiveButton(getString(R.string.retry)) { dialogInterface, _ ->
            dialogInterface.cancel()
            viewModel.getSubscriptionBundles()
        }

        dialogBuilder.setCancelable(false)

        val dialog = dialogBuilder.create()
        dialog.show()
    }
}
