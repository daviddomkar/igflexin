package com.appapply.igflexin.ui.subscriptionselectiondetail

import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.Observer
import androidx.lifecycle.Transformations
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import com.android.billingclient.api.Purchase
import com.appapply.igflexin.MainActivityViewModel

import com.appapply.igflexin.R
import com.appapply.igflexin.billing.Product
import com.appapply.igflexin.events.Event
import com.appapply.igflexin.events.EventObserver
import com.appapply.igflexin.pojo.Subscription
import com.appapply.igflexin.pojo.User
import kotlinx.android.synthetic.main.subscription_selection_detail_fragment.*
import org.koin.androidx.viewmodel.ext.android.sharedViewModel
import org.koin.androidx.viewmodel.ext.android.viewModel

class SubscriptionSelectionDetailFragment : Fragment() {

    private val subscriptionSelectionDetailViewModel: SubscriptionSelectionDetailViewModel by viewModel()
    private val mainActivityViewModel: MainActivityViewModel by sharedViewModel()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.subscription_selection_detail_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        mainActivityViewModel.disableBackNavigation(false)

        val subscriptionID = SubscriptionSelectionDetailFragmentArgs.fromBundle(arguments).subscriptionID

        val viewManager = LinearLayoutManager(requireContext())
        val viewAdapter = SubscriptionSelectionDetailAdapter(findNavController()) {
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

        subscriptionSelectionDetailViewModel.getSubscriptionDetailsLiveData(subscriptionList).observe(this, Observer { list ->
            subscriptionDetailsProgressBar.visibility = View.GONE

            val sortedList = list.sortedWith(compareBy { getSubscriptionIndex(it.id ) })

            for (subscription in sortedList) {

                subscription.title = getSubscriptionTitle(subscription)
                subscription.description = getSubscriptionDescription(subscription)

            }

            viewAdapter.setList(sortedList)
        })

        Transformations.switchMap(subscriptionSelectionDetailViewModel.getSubscriptionPurchases()) { list ->
            return@switchMap Transformations.switchMap(subscriptionSelectionDetailViewModel.getUserLiveData()) { user ->
                val liveData: MutableLiveData<Event<Pair<List<Purchase>?, User>>> = MutableLiveData()
                liveData.value = Event(Pair(list.getContentIfNotHandled(), user))
                return@switchMap liveData
            }

            // TODO Remove event, native observer is probably enough
        }.observe(this, EventObserver { pair ->
            pair.first?.let {
                for (purchase in it) {
                    subscriptionSelectionDetailViewModel.verifySubscriptionPurchase(pair.second.uid!!, purchase.orderId, purchase.purchaseToken)
                }
            }
        })

        subscriptionSelectionDetailViewModel.getSubscriptionPurchases().observe(this, Observer {

        })
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
