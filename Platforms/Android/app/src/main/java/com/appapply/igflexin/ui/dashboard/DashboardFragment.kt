package com.appapply.igflexin.ui.dashboard

import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.os.bundleOf
import androidx.lifecycle.Observer
import androidx.lifecycle.Transformations
import androidx.navigation.fragment.findNavController
import com.appapply.igflexin.MainActivityViewModel
import com.appapply.igflexin.R
import com.appapply.igflexin.events.EventObserver
import org.koin.androidx.viewmodel.ext.android.sharedViewModel
import org.koin.androidx.viewmodel.ext.android.viewModel

class DashboardFragment : Fragment() {

    private val mainActivityViewModel: MainActivityViewModel by sharedViewModel()
    private val dashboardViewModel: DashboardViewModel by viewModel()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View {
        return inflater.inflate(R.layout.dashboard_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        mainActivityViewModel.getDrawerItemSelectedLiveData().observe(this, EventObserver{
            if(it.itemId == R.id.signOutMenuItem) {
                dashboardViewModel.signOut()
            }
        })

        /*
        Transformations.switchMap(dashboardViewModel.getSignedInLiveData()) {
            if(!it) {
                if (!findNavController().popBackStack(R.id.welcomeScreenFragment, false)) findNavController().navigate(R.id.action_dashboardFragment_to_nav_graph_auth)
                return@switchMap null
            } else {
                return@switchMap dashboardViewModel.getUserLiveData()
            }
        }.observe(this, Observer { user ->
            user?.emailVerified?.let {
                if (!it) {
                    if(findNavController().currentDestination?.id == R.id.dashboardFragment)
                        findNavController().navigate(R.id.action_dashboardFragment_to_emailVerificationFragment)
                }
            }
        })*/

        /*
        dashboardViewModel.getSignedInLiveData().observe(this, Observer {
            if(!it) {
                //findNavController().navigate(R.id.action_dashboardFragment_to_nav_graph_auth)

            }
        })*/
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        //mainActivityViewModel.showProgressBar(false, false)
    }
}
