package com.appapply.igflexin.ui.auth.howitworks

import androidx.lifecycle.ViewModelProviders
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.navigation.fragment.findNavController

import com.appapply.igflexin.R
import kotlinx.android.synthetic.main.how_it_works_fragment.*

class HowItWorksFragment : Fragment() {

    companion object {
        fun newInstance() = HowItWorksFragment()
    }

    private lateinit var viewModel: HowItWorksViewModel

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.how_it_works_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        viewModel = ViewModelProviders.of(this).get(HowItWorksViewModel::class.java)

        continueButton.setOnClickListener {
            findNavController().popBackStack()
        }
    }

}
