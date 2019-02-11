package com.appapply.igflexin.ui.app.dashboard

import android.graphics.Color
import android.opengl.Visibility
import android.os.Bundle
import android.provider.ContactsContract
import android.util.Log
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.AdapterView
import androidx.core.content.ContextCompat
import androidx.lifecycle.Observer

import com.appapply.igflexin.R
import com.appapply.igflexin.common.StatsPeriod
import com.appapply.igflexin.common.StatusCode
import com.appapply.igflexin.common.getStringStatusCode
import com.appapply.igflexin.model.InstagramAccount
import com.google.android.material.tabs.TabLayout
import com.jjoe64.graphview.helper.DateAsXAxisLabelFormatter
import com.jjoe64.graphview.series.DataPoint
import com.jjoe64.graphview.series.LineGraphSeries
import kotlinx.android.synthetic.main.dashboard_fragment.*
import org.koin.androidx.viewmodel.ext.android.viewModel
import java.text.DateFormat
import java.text.SimpleDateFormat
import java.util.*

class DashboardFragment : Fragment() {

    private val viewModel: DashboardViewModel by viewModel()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.dashboard_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        progressBar.visibility = View.VISIBLE

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

        viewModel.instagramRecordsLiveData.observe(this, Observer {
            Log.d("IGFlexin_dashboard", "Records live: " + getStringStatusCode(it.status))

            if (it.status == StatusCode.SUCCESS) {
                val data = it.data!!

                val dataPoints = data.map {
                    Log.d("IGFlexin_dashboard", "Record time: ${it.timestamp}, followers: ${it.followers}")
                    DataPoint(it.timestamp.toDate(), it.followers.toDouble())
                }

                val cal = Calendar.getInstance()
                val end = cal.time
                when (tabLayout.selectedTabPosition) {
                    0 -> {
                        cal.add(Calendar.HOUR, -24)
                        graphTotal.gridLabelRenderer.labelFormatter = DateAsXAxisLabelFormatter(requireActivity(), SimpleDateFormat("HH:mm", Locale.getDefault()))
                    }
                    1 -> {
                        cal.add(Calendar.HOUR, -7 * 24)
                        graphTotal.gridLabelRenderer.labelFormatter = DateAsXAxisLabelFormatter(requireActivity(), SimpleDateFormat("dd.MM", Locale.getDefault()))
                    }
                    else -> {
                        cal.add(Calendar.HOUR, -7 * 24 * 30)
                        graphTotal.gridLabelRenderer.labelFormatter = DateAsXAxisLabelFormatter(requireActivity(), SimpleDateFormat("dd.MM", Locale.getDefault()))
                    }
                }
                val start = cal.time

                graphTotal.removeAllSeries()

                val series = LineGraphSeries<DataPoint>(dataPoints.toTypedArray())

                series.isDrawBackground = true
                series.color = Color.TRANSPARENT
                series.backgroundColor = ContextCompat.getColor(requireContext(), R.color.colorAccent)

                graphTotal.addSeries(series)

                graphTotal.gridLabelRenderer.numHorizontalLabels = 3 // only 4 because of the space

                graphTotal.viewport.setMinX(start.time.toDouble())
                graphTotal.viewport.setMaxX(end.time.toDouble())
                graphTotal.viewport.isXAxisBoundsManual = true

                graphTotal.gridLabelRenderer.setHumanRounding(true)

                graphsProgressBar.visibility = View.GONE
                graphsLayout.visibility = View.VISIBLE
            }
        })

        spinner.onItemSelectedListener = object: AdapterView.OnItemSelectedListener {
            override fun onNothingSelected(parent: AdapterView<*>?) {

            }

            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                parent?.let {
                    if (it.adapter is InstagramAccountsAdapter) {
                        val account = (it.adapter as InstagramAccountsAdapter).instagramAccounts[position]
                        graphsLayout.visibility = View.GONE
                        graphsProgressBar.visibility = View.VISIBLE
                        viewModel.setStatsID(account.id)
                    }
                }
            }
        }

        tabLayout.addOnTabSelectedListener(object: TabLayout.BaseOnTabSelectedListener<TabLayout.Tab> {
            override fun onTabReselected(tab: TabLayout.Tab) {

            }

            override fun onTabUnselected(tab: TabLayout.Tab) {

            }

            override fun onTabSelected(tab: TabLayout.Tab) {
                graphsLayout.visibility = View.GONE
                graphsProgressBar.visibility = View.VISIBLE
                viewModel.setStatsPeriod(tab.position)
            }
        })
    }

    private fun populateSpinner(accounts: List<InstagramAccount>) {
        if ((spinner.adapter != null && spinner.adapter.count != accounts.size) || spinner.adapter == null) {
            spinner.adapter = InstagramAccountsAdapter(requireActivity(), R.layout.instagram_account_spinner_row, accounts)
        }
    }
}
