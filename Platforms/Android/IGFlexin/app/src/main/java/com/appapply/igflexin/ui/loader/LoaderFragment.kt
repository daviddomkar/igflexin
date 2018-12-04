package com.appapply.igflexin.ui.loader

import android.os.Bundle
import android.util.Log
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.Observer
import androidx.navigation.fragment.findNavController

import com.appapply.igflexin.R
import com.appapply.igflexin.common.StatusCode
import com.appapply.igflexin.events.EventObserver
import org.koin.androidx.viewmodel.ext.android.viewModel

class LoaderFragment : Fragment() {

    private val viewModel: LoaderViewModel by viewModel()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.loader_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        Log.d("IGFlexin_navigation", "LoaderFragment onActivityCreated")

        viewModel.loggedInAndHasEmailVerifiedLiveData.observe(this, Observer {
            if (it) {
                Log.d("IGFlexin_flow", "Signed in")
                if (!viewModel.subscriptionPurchasedCalled) {
                    viewModel.subscriptionPurchasedCalled = true
                    viewModel.checkIfUserHasPurchasedSubscription()
                }
            } else {
                viewModel.subscriptionPurchasedCalled = false
                Log.d("IGFlexin_navigation", "Navigating to AuthFragment")
                viewModel.loggedInAndHasEmailVerifiedLiveData.removeObservers(this)
                viewModel.subscriptionGetCacheLiveData.removeObservers(this)
                viewModel.subscriptionGetServerLiveData.removeObservers(this)
                findNavController().navigate(R.id.action_loaderFragment_to_authFragment)
            }
        })

        viewModel.subscriptionGetServerLiveData.observe(this, EventObserver {
            Log.d("IGFlexin", "jejda server")
            when (it.status) {
                StatusCode.SUCCESS -> {
                    viewModel.subscriptionPurchasedCalled = false

                    if (it.data!!.verified) {
                        findNavController().navigate(R.id.action_loaderFragment_to_appFragment)
                    } else {
                        viewModel.loggedInAndHasEmailVerifiedLiveData.removeObservers(this)
                        viewModel.subscriptionGetCacheLiveData.removeObservers(this)
                        viewModel.subscriptionGetServerLiveData.removeObservers(this)
                        findNavController().navigate(R.id.action_loaderFragment_to_subscriptionFragment)
                    }
                }
                StatusCode.NETWORK_ERROR -> {
                    Log.d("IGFlexin", "Error retrieving subscription from server, trying to find it in local cache")
                    viewModel.checkForPurchasedSubscriptionInCache()
                }
                StatusCode.ERROR -> {
                    viewModel.subscriptionPurchasedCalled = false
                    viewModel.loggedInAndHasEmailVerifiedLiveData.removeObservers(this)
                    viewModel.subscriptionGetCacheLiveData.removeObservers(this)
                    viewModel.subscriptionGetServerLiveData.removeObservers(this)
                    findNavController().navigate(R.id.action_loaderFragment_to_subscriptionFragment)
                }
            }
        })

        viewModel.subscriptionGetCacheLiveData.observe(this, EventObserver {
            Log.d("IGFlexin", "jejda cache")
            when (it.status) {
                StatusCode.SUCCESS -> {
                    viewModel.subscriptionPurchasedCalled = false

                    if (it.data!!.verified) {
                        findNavController().navigate(R.id.action_loaderFragment_to_appFragment)
                    } else {
                        viewModel.loggedInAndHasEmailVerifiedLiveData.removeObservers(this)
                        viewModel.subscriptionGetCacheLiveData.removeObservers(this)
                        viewModel.subscriptionGetServerLiveData.removeObservers(this)
                        findNavController().navigate(R.id.action_loaderFragment_to_subscriptionFragment)
                    }
                }
                StatusCode.ERROR -> {
                    viewModel.subscriptionPurchasedCalled = false
                    viewModel.loggedInAndHasEmailVerifiedLiveData.removeObservers(this)
                    viewModel.subscriptionGetCacheLiveData.removeObservers(this)
                    viewModel.subscriptionGetServerLiveData.removeObservers(this)
                    findNavController().navigate(R.id.action_loaderFragment_to_subscriptionFragment)
                }
            }
        })
    }
}
