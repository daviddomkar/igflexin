package com.appapply.igflexin.ui.app

import android.os.Bundle
import android.util.Log
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.Observer
import androidx.navigation.fragment.findNavController

import com.appapply.igflexin.R
import com.appapply.igflexin.common.OnBackPressedFinishListener
import com.appapply.igflexin.common.StatusCode
import org.koin.androidx.viewmodel.ext.android.viewModel

class AppFragment : Fragment(), OnBackPressedFinishListener {

    private val viewModel: AppViewModel by viewModel()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.app_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        viewModel.subscriptionLiveData.observe(this, Observer {
            when (it.status) {
                StatusCode.SUCCESS -> {
                    if (!it.data!!.verified) {
                        findNavController().popBackStack()
                    }
                }
                StatusCode.ERROR -> {

                }
            }
        })
    }

    override fun onBackPressed(): Boolean {
        return false
    }
}
