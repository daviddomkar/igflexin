package com.appapply.igflexin.ui

import androidx.lifecycle.ViewModelProviders
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.navigation.fragment.findNavController

import com.appapply.igflexin.R

class AddInstagramAccountFragment : Fragment() {

    companion object {
        fun newInstance() = AddInstagramAccountFragment()
    }

    private lateinit var viewModel: AddInstagramAccountViewModel

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.add_instagram_account_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        viewModel = ViewModelProviders.of(this).get(AddInstagramAccountViewModel::class.java)
        // TODO: Use the ViewModel
    }
}
