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
import org.koin.androidx.viewmodel.ext.android.viewModel

class LoaderFragment : Fragment() {

    private val viewModel: LoaderViewModel by viewModel()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.loader_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        Log.d("IGFlexin", "loader")

        viewModel.userLiveData.observe(this, Observer { resource ->
            resource?.let { it ->
                if (it.status == StatusCode.SUCCESS) {
                    it.data?.let {
                        Log.d("IGFlexin", it.uid)
                        if (it.emailVerified) {
                            viewModel.userLiveData.removeObservers(this)
                            findNavController().navigate(R.id.action_loaderFragment_to_authFragment)
                        }
                    }
                }
            }
        })
    }
}
