package com.appapply.igflexin.ui.instagramaccountmanagement

import android.arch.lifecycle.ViewModelProviders
import android.os.Bundle
import android.support.v4.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup

import com.appapply.igflexin.R

class InstagramAccountManagementFragment : Fragment() {

    companion object {
        fun newInstance() = InstagramAccountManagementFragment()
    }

    private lateinit var viewModel: InstagramAccountManagementViewModel

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.instagram_account_management_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        viewModel = ViewModelProviders.of(this).get(InstagramAccountManagementViewModel::class.java)
        // TODO: Use the ViewModel
    }

}
