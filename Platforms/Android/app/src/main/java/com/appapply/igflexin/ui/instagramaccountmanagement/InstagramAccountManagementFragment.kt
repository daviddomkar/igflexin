package com.appapply.igflexin.ui.instagramaccountmanagement

import androidx.lifecycle.ViewModelProviders
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.navigation.fragment.findNavController

import com.appapply.igflexin.R
import kotlinx.android.synthetic.main.instagram_account_management_fragment.*

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

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        floatingActionButton.setOnClickListener {
            findNavController().navigate(R.id.action_instagramAccountManagementFragment_to_nav_graph_add_ig_account)
        }
    }

}
