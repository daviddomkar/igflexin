package com.appapply.igflexin.ui.app.subscriptionmanagement.subscriptiontab

import android.os.Bundle
import android.util.Log
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.Observer
import androidx.lifecycle.Transformations
import androidx.recyclerview.widget.LinearLayoutManager

import com.appapply.igflexin.R
import com.appapply.igflexin.billing.Product
import com.appapply.igflexin.common.StatusCode
import com.appapply.igflexin.model.SubscriptionBundle
import com.appapply.igflexin.ui.app.subscriptionmanagement.SubscriptionManagementViewModel
import kotlinx.android.synthetic.main.period_fragment.*
import org.koin.androidx.viewmodel.ext.android.sharedViewModel
import org.koin.androidx.viewmodel.ext.android.viewModel

class SubscriptionTabFragment : Fragment() {

    private val viewModel: SubscriptionTabViewModel by viewModel()
    private val subscriptionManagementViewModel: SubscriptionManagementViewModel by sharedViewModel()
    private lateinit var viewAdapter: SubscriptionTabAdapter

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.subscription_tab_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        Log.d("IGFlexin_subscriptions", "Period: " + arguments?.getString("period"))

        val viewManager = LinearLayoutManager(requireContext())

        viewAdapter = SubscriptionTabAdapter(requireContext()) {
            Log.d("IGFlexin_subscription", "Ready to upgrade/downgrade to $it")
            viewModel.subscriptionLiveData.value?.data?.subscriptionID?.let { oldSKU ->
                subscriptionManagementViewModel.lastSubscription = oldSKU
                viewModel.upgradeDowngradeSubscription(requireActivity(), oldSKU, it)
            }
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

                    loop@ for (rawBundle in rawList) {

                        when (arguments?.getString("period")) {
                            Product.WEEKLY_BASIC_SUBSCRIPTION -> {
                                if (!rawBundle.id.startsWith("weekly"))
                                    continue@loop
                            }
                            Product.MONTHLY_BASIC_SUBSCRIPTION -> {
                                if (!rawBundle.id.startsWith("mothly"))
                                    continue@loop
                            }
                            Product.QUARTERLY_BASIC_SUBSCRIPTION -> {
                                if (!rawBundle.id.startsWith("quarterly"))
                                    continue@loop
                            }
                        }

                        list.add(SubscriptionBundle(rawBundle.id, getString(rawBundle.title), rawBundle.price, getString(rawBundle.description), getString(rawBundle.restriction)))
                    }

                    viewAdapter.setList(list)
                    progressBar.visibility = View.GONE
                }
            }
        })
    }
}
