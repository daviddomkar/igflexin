package com.appapply.igflexin.ui.welcomescreen

import androidx.lifecycle.ViewModelProviders
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup

import com.appapply.igflexin.R

class WelcomeScreenFragment : Fragment() {

    companion object {
        fun newInstance() = WelcomeScreenFragment()
    }

    private lateinit var viewModel: WelcomeScreenViewModel

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.welcome_screen_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        viewModel = ViewModelProviders.of(this).get(WelcomeScreenViewModel::class.java)
        // TODO: Use the ViewModel
    }

}
