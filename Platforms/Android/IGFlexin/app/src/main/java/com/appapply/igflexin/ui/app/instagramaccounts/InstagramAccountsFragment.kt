package com.appapply.igflexin.ui.app.instagramaccounts

import androidx.lifecycle.ViewModelProviders
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup

import com.appapply.igflexin.R

class InstagramAccountsFragment : Fragment() {

    companion object {
        fun newInstance() = InstagramAccountsFragment()
    }

    private lateinit var viewModel: InstagramAccountsViewModel

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.instagram_accounts_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        viewModel = ViewModelProviders.of(this).get(InstagramAccountsViewModel::class.java)
        // TODO: Use the ViewModel
    }

}
