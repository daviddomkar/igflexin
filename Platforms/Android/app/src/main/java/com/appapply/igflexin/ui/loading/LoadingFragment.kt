package com.appapply.igflexin.ui.loading

import android.os.Bundle
import android.util.Log.d
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.appapply.igflexin.R
import org.koin.androidx.viewmodel.ext.android.viewModel

class LoadingFragment : Fragment() {

    private val loadingViewModel: LoadingViewModel by viewModel()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.loading_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        d("IGFlexin", "Jejda")
    }
}
