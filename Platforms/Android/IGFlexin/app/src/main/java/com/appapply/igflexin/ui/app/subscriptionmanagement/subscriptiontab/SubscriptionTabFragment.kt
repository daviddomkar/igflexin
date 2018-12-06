package com.appapply.igflexin.ui.app.subscriptionmanagement.subscriptiontab

import android.os.Bundle
import android.util.Log
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.LinearLayoutManager

import com.appapply.igflexin.R
import com.appapply.igflexin.billing.Product
import com.appapply.igflexin.common.StatusCode
import com.appapply.igflexin.model.SubscriptionBundle
import kotlinx.android.synthetic.main.period_fragment.*
import org.koin.androidx.viewmodel.ext.android.viewModel

class SubscriptionTabFragment : Fragment() {

    private val viewModel: SubscriptionTabViewModel by viewModel()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.subscription_tab_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        Log.d("IGFlexin_subscriptions", "Period: " + arguments?.getString("period"))

        val viewManager = LinearLayoutManager(requireContext())

        val viewAdapter = SubscriptionTabAdapter {
            Log.d("IGFlexin_subscription", "Ready to purchase $it")
            // viewModel.purchaseSubscription(requireActivity(), it)
        }

        subscriptionsRecyclerView.setHasFixedSize(true)
        subscriptionsRecyclerView.isNestedScrollingEnabled = false

        subscriptionsRecyclerView.apply {
            layoutManager = viewManager
            adapter = viewAdapter
        }

        viewModel.subscriptionBundlesLiveData.observe(this, Observer {
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
