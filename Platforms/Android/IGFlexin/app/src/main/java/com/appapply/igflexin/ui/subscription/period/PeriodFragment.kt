package com.appapply.igflexin.ui.subscription.period

import android.os.Bundle
import android.util.Log
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.appcompat.app.AlertDialog
import androidx.lifecycle.Observer
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager

import com.appapply.igflexin.R
import com.appapply.igflexin.common.BillingStatusCode
import com.appapply.igflexin.common.StatusCode
import com.appapply.igflexin.model.SubscriptionPeriod
import kotlinx.android.synthetic.main.period_fragment.*
import org.koin.androidx.viewmodel.ext.android.viewModel

class PeriodFragment : Fragment() {

    private val viewModel: PeriodViewModel by viewModel()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.period_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        val viewManager = object : LinearLayoutManager(requireContext()) {
            override fun canScrollVertically(): Boolean {
                return false
            }
        }

        val viewAdapter = PeriodAdapter(findNavController())

        subscriptionsRecyclerView.setHasFixedSize(true)
        subscriptionsRecyclerView.isNestedScrollingEnabled = false

        subscriptionsRecyclerView.apply {
            layoutManager = viewManager
            adapter = viewAdapter
        }

        viewModel.subscriptionPeriodsLiveData.observe(this, Observer {
            when (it.status) {
                StatusCode.PENDING -> {
                    viewAdapter.setList(listOf())
                    progressBar.visibility = View.VISIBLE
                }
                StatusCode.SUCCESS -> {
                    val rawList = it.data!!

                    val list = ArrayList<SubscriptionPeriod>()

                    for (rawPeriod in rawList) {
                        list.add(SubscriptionPeriod(rawPeriod.id, getString(rawPeriod.title), "Starting at " + rawPeriod.price))
                    }

                    viewAdapter.setList(list)

                    progressBar.visibility = View.GONE
                }
                // TODO Extract string resource

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
            viewModel.getSubscriptionPeriods()
        }

        dialogBuilder.setCancelable(false)

        val dialog = dialogBuilder.create()
        dialog.show()
    }
}
