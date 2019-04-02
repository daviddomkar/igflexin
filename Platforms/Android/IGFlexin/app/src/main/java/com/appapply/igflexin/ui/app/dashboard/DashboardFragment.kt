package com.appapply.igflexin.ui.app.dashboard

import android.os.Bundle
import android.util.Log
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.AdapterView
import androidx.lifecycle.Observer

import com.appapply.igflexin.R
import com.appapply.igflexin.common.InstagramStatusCode
import com.appapply.igflexin.common.StatusCode
import com.appapply.igflexin.common.getStringStatusCode
import com.appapply.igflexin.model.InstagramAccount
import kotlinx.android.synthetic.main.dashboard_fragment.*
import org.koin.androidx.viewmodel.ext.android.viewModel

class DashboardFragment : Fragment() {

    private val viewModel: DashboardViewModel by viewModel()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.dashboard_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        progressBar.visibility = View.VISIBLE

        val adapter = DashboardViewPagerAdapter(requireContext(), childFragmentManager)

        viewPager.adapter = adapter
        viewPager.offscreenPageLimit = adapter.count - 1

        tabs.setupWithViewPager(viewPager)

        viewModel.instagramAccountsLiveData.observe(this, Observer {
            progressBar.visibility = View.GONE
            when (it.status) {
                StatusCode.SUCCESS -> {
                    if (it.data!!.isEmpty()) {
                        mainLayout.visibility = View.GONE
                        errorTextView.text = "No accounts found!"
                        errorLayout.visibility = View.VISIBLE
                    } else {
                        mainLayout.visibility = View.VISIBLE
                        errorLayout.visibility = View.GONE

                        populateSpinner(it.data)
                    }
                }
                StatusCode.ERROR -> {
                    mainLayout.visibility = View.GONE
                    errorTextView.text = "Error loading data!"
                    errorLayout.visibility = View.VISIBLE
                }
            }
        })

        viewModel.instagramStatisticsLiveData.observe(this, Observer {
            Log.d("IGFlexin_dashboard", "Records live: " + getStringStatusCode(it.status))

            if (it.status == StatusCode.SUCCESS || it.status == InstagramStatusCode.DATA_EMPTY) {
                graphsProgressBar.visibility = View.GONE
                viewPager.visibility = View.VISIBLE
            } else {
                graphsProgressBar.visibility = View.VISIBLE
                viewPager.visibility = View.GONE
            }
        })

        spinner.onItemSelectedListener = object: AdapterView.OnItemSelectedListener {
            override fun onNothingSelected(parent: AdapterView<*>?) {

            }

            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                parent?.let {
                    if (it.adapter is InstagramAccountsSpinnerAdapter) {
                        val account = (it.adapter as InstagramAccountsSpinnerAdapter).instagramAccounts[position]
                        graphsProgressBar.visibility = View.VISIBLE
                        viewPager.visibility = View.GONE
                        viewModel.setStatsID(account.id)
                    }
                }
            }
        }
    }

    private fun populateSpinner(accounts: List<InstagramAccount>) {
        if ((spinner.adapter != null && spinner.adapter.count != accounts.size) || spinner.adapter == null) {
            spinner.adapter = InstagramAccountsSpinnerAdapter(requireActivity(), R.layout.instagram_account_spinner_row, accounts)
        }
    }
}
