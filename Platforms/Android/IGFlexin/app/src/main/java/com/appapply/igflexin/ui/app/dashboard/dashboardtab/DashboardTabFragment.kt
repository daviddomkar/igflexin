package com.appapply.igflexin.ui.app.dashboard.dashboardtab

import androidx.lifecycle.ViewModelProviders
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup

import com.appapply.igflexin.R

class DashboardTabFragment : Fragment() {

    companion object {
        fun newInstance() = DashboardTabFragment()
    }

    private lateinit var viewModel: DashboardTabViewModel

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.dashboard_tab_fragment2, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        viewModel = ViewModelProviders.of(this).get(DashboardTabViewModel::class.java)
        // TODO: Use the ViewModel
    }

}
