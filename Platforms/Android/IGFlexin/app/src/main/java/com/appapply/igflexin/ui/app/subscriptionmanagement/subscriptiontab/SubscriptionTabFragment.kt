package com.appapply.igflexin.ui.app.subscriptionmanagement.subscriptiontab

import androidx.lifecycle.ViewModelProviders
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup

import com.appapply.igflexin.R

class SubscriptionTabFragment : Fragment() {

    companion object {
        fun newInstance() = SubscriptionTabFragment()
    }

    private lateinit var viewModel: SubscriptionTabViewModel

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.subscription_tab_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        viewModel = ViewModelProviders.of(this).get(SubscriptionTabViewModel::class.java)
        // TODO: Use the ViewModel
    }

}
