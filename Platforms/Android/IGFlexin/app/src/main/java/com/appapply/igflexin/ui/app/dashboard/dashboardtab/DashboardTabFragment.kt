package com.appapply.igflexin.ui.app.dashboard.dashboardtab

import android.graphics.Color
import android.os.Bundle
import android.util.Log
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.lifecycle.Observer

import com.appapply.igflexin.R
import com.appapply.igflexin.common.InstagramStatusCode
import com.appapply.igflexin.common.Resource
import com.appapply.igflexin.common.StatsPeriod
import com.appapply.igflexin.common.StatusCode
import com.appapply.igflexin.model.InstagramStatistics
import com.jjoe64.graphview.series.DataPoint
import com.jjoe64.graphview.series.LineGraphSeries
import kotlinx.android.synthetic.main.dashboard_tab_fragment.*
import org.koin.androidx.viewmodel.ext.android.viewModel
import com.jjoe64.graphview.helper.StaticLabelsFormatter
import com.jjoe64.graphview.series.BarGraphSeries
import java.text.SimpleDateFormat
import java.util.*

class DashboardTabFragment : Fragment() {

    private val viewModel: DashboardTabViewModel by viewModel()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.dashboard_tab_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        Log.d("IGFlexin_dashboardTab", "Period: " + arguments?.getInt("period"))
        viewModel.period = arguments?.getInt("period")!!

        viewModel.instagramStatisticsLiveData.observe(this, StatisticsObserver())

        graphTotal.title = "Total followers"
        graphNew.title = "New followers"
    }

    // Because Kotlin is dump as **** this must be separated from observe functions
    inner class StatisticsObserver : Observer<Resource<InstagramStatistics>> {
        override fun onChanged(it: Resource<InstagramStatistics>) {
            Log.d("IGFlexin_dashboardTab", "Just to avoid crashing the app: " + viewModel.period)

            when (it.status) {
                StatusCode.SUCCESS -> {

                    val data = it.data!!

                    when(viewModel.period) {

                        StatsPeriod.DAY -> {
                            Log.d("IGFlexin_dashboard", "Hours: " + data.hoursOfDay.size)

                            val dataPoints = ArrayList<DataPoint>()
                            val dataPointsBar = ArrayList<DataPoint>()

                            var minFollowers = Double.MAX_VALUE
                            var maxFollowers = Double.MIN_VALUE

                            if (data.hoursOfDay.indexOf(null) == -1) {
                                var index = 0
                                var previousFollowers = data.hoursOfDay.first()!!.toDouble()

                                data.hoursOfDay.forEach {
                                    if (it!!.toInt().toDouble() < minFollowers) {
                                        minFollowers = it.toInt().toDouble()
                                    }
                                    if (it.toInt().toDouble() > maxFollowers) {
                                        maxFollowers = it.toInt().toDouble()
                                    }
                                    dataPoints.add(DataPoint(index.toDouble(), it.toInt().toDouble()))
                                    dataPointsBar.add(DataPoint(index.toDouble(), it.toInt().toDouble() - previousFollowers))
                                    previousFollowers = it.toInt().toDouble()
                                    index++
                                }
                            } else {
                                val length = data.hoursOfDay.size - data.hoursOfDay.indexOf(null)

                                for (i in 0..(length - 1)) {
                                    dataPoints.add(DataPoint(i.toDouble(), 0.0))
                                    dataPointsBar.add(DataPoint(i.toDouble(), 0.0))
                                }

                                var index = length
                                var previousFollowers = data.hoursOfDay.first()!!.toDouble()

                                data.hoursOfDay.forEach {
                                    if (dataPoints.size == data.hoursOfDay.size) { return@forEach }
                                    if (it!!.toInt().toDouble() < minFollowers) {
                                        minFollowers = it.toInt().toDouble()
                                    }
                                    if (it.toInt().toDouble() > maxFollowers) {
                                        maxFollowers = it.toInt().toDouble()
                                    }
                                    dataPoints.add(DataPoint(index.toDouble(), it.toInt().toDouble()))
                                    dataPointsBar.add(DataPoint(index.toDouble(), it.toInt().toDouble() - previousFollowers))
                                    previousFollowers = it.toInt().toDouble()
                                    index++
                                }
                            }

                            graphTotal.removeAllSeries()
                            graphNew.removeAllSeries()

                            val series = LineGraphSeries<DataPoint>(dataPoints.toTypedArray())
                            val seriesBar = BarGraphSeries<DataPoint>(dataPointsBar.toTypedArray())

                            series.isDrawBackground = true
                            series.color = Color.TRANSPARENT
                            series.backgroundColor = ContextCompat.getColor(requireContext(), R.color.colorAccent)

                            seriesBar.valuesOnTopSize = 30.0f
                            seriesBar.isDrawValuesOnTop = true
                            seriesBar.spacing = 0
                            seriesBar.color = ContextCompat.getColor(requireContext(), R.color.colorAccent)

                            graphTotal.addSeries(series)
                            graphNew.addSeries(seriesBar)

                            graphTotal.viewport.setMinX(0.0)
                            graphTotal.viewport.setMaxX((data.hoursOfDay.size - 1).toDouble())
                            graphTotal.viewport.isXAxisBoundsManual = true

                            graphNew.viewport.setMinX(0.0)
                            graphNew.viewport.setMaxX((data.hoursOfDay.size - 1).toDouble())
                            graphNew.viewport.isXAxisBoundsManual = true

                            if (minFollowers - 5.0 <= 0) {
                                graphTotal.viewport.setMinY(0.0)
                            } else {
                                graphTotal.viewport.setMinY(minFollowers - 5.0)
                            }

                            graphTotal.viewport.setMaxY(maxFollowers + 5.0)
                            graphTotal.viewport.isYAxisBoundsManual = true

                            val staticLabelsFormatter = StaticLabelsFormatter(graphTotal)
                            val format = SimpleDateFormat.getDateTimeInstance()
                            val labels = ArrayList<String>()

                            for (i in 0..(data.hoursOfDay.size - 1)) {
                                when (i) {
                                    0 -> labels.add(format.format(Date(data.lastAction.time - (1000 * 60 * 60 * 24))))
                                    data.hoursOfDay.size - 1 -> labels.add(format.format(data.lastAction))
                                    else -> labels.add("")
                                }
                            }

                            staticLabelsFormatter.setHorizontalLabels(labels.toTypedArray())

                            graphTotal.gridLabelRenderer.labelFormatter = staticLabelsFormatter
                            graphTotal.gridLabelRenderer.setHumanRounding(false, true)

                            graphNew.gridLabelRenderer.labelFormatter = staticLabelsFormatter
                            graphNew.gridLabelRenderer.setHumanRounding(false, true)
                        }

                        StatsPeriod.WEEK -> {
                            Log.d("IGFlexin_dashboard", "Days Week: " + data.daysOfWeek.size)

                            val dataPoints = ArrayList<DataPoint>()
                            val dataPointsBar = ArrayList<DataPoint>()

                            var minFollowers = Double.MAX_VALUE
                            var maxFollowers = Double.MIN_VALUE

                            if (data.daysOfWeek.indexOf(null) == -1) {
                                var index = 0
                                var previousFollowers = data.daysOfWeek.first()!!.toDouble()

                                data.daysOfWeek.forEach {
                                    if (it!!.toInt().toDouble() < minFollowers) {
                                        minFollowers = it.toInt().toDouble()
                                    }
                                    if (it.toInt().toDouble() > maxFollowers) {
                                        maxFollowers = it.toInt().toDouble()
                                    }
                                    dataPoints.add(DataPoint(index.toDouble(), it.toInt().toDouble()))
                                    dataPointsBar.add(DataPoint(index.toDouble(), it.toInt().toDouble() - previousFollowers))
                                    previousFollowers = it.toInt().toDouble()
                                    index++
                                }
                            } else {
                                val length = data.daysOfWeek.size - data.daysOfWeek.indexOf(null)

                                for (i in 0..(length - 1)) {
                                    dataPoints.add(DataPoint(i.toDouble(), 0.0))
                                    dataPointsBar.add(DataPoint(i.toDouble(), 0.0))
                                }

                                var index = length
                                var previousFollowers = data.daysOfWeek.first()!!.toDouble()

                                data.daysOfWeek.forEach {
                                    if (dataPoints.size == data.daysOfWeek.size) { return@forEach }
                                    if (it!!.toInt().toDouble() < minFollowers) {
                                        minFollowers = it.toInt().toDouble()
                                    }
                                    if (it.toInt().toDouble() > maxFollowers) {
                                        maxFollowers = it.toInt().toDouble()
                                    }
                                    dataPoints.add(DataPoint(index.toDouble(), it.toInt().toDouble()))
                                    dataPointsBar.add(DataPoint(index.toDouble(), it.toInt().toDouble() - previousFollowers))
                                    previousFollowers = it.toInt().toDouble()
                                    index++
                                }
                            }

                            graphTotal.removeAllSeries()
                            graphNew.removeAllSeries()

                            val series = LineGraphSeries<DataPoint>(dataPoints.toTypedArray())
                            val seriesBar = BarGraphSeries<DataPoint>(dataPointsBar.toTypedArray())

                            series.isDrawBackground = true
                            series.color = Color.TRANSPARENT
                            series.backgroundColor = ContextCompat.getColor(requireContext(), R.color.colorAccent)

                            seriesBar.valuesOnTopSize = 30.0f
                            seriesBar.isDrawValuesOnTop = true
                            seriesBar.spacing = 0
                            seriesBar.color = ContextCompat.getColor(requireContext(), R.color.colorAccent)

                            graphTotal.addSeries(series)
                            graphNew.addSeries(seriesBar)

                            graphTotal.viewport.setMinX(0.0)
                            graphTotal.viewport.setMaxX((data.daysOfWeek.size - 1).toDouble())
                            graphTotal.viewport.isXAxisBoundsManual = true

                            graphNew.viewport.setMinX(0.0)
                            graphNew.viewport.setMaxX((data.daysOfWeek.size - 1).toDouble())
                            graphNew.viewport.isXAxisBoundsManual = true

                            if (minFollowers - 5.0 <= 0) {
                                graphTotal.viewport.setMinY(0.0)
                            } else {
                                graphTotal.viewport.setMinY(minFollowers - 5.0)
                            }

                            graphTotal.viewport.setMaxY(maxFollowers + 5.0)
                            graphTotal.viewport.isYAxisBoundsManual = true

                            val staticLabelsFormatter = StaticLabelsFormatter(graphTotal)
                            val format = SimpleDateFormat.getDateTimeInstance()
                            val labels = ArrayList<String>()

                            for (i in 0..(data.daysOfWeek.size - 1)) {
                                when (i) {
                                    0 -> labels.add(format.format(Date(data.lastAction.time - (1000 * 60 * 60 * 24 * 7))))
                                    data.daysOfWeek.size - 1 -> labels.add(format.format(data.lastAction))
                                    else -> labels.add("")
                                }
                            }

                            staticLabelsFormatter.setHorizontalLabels(labels.toTypedArray())

                            graphTotal.gridLabelRenderer.labelFormatter = staticLabelsFormatter
                            graphTotal.gridLabelRenderer.setHumanRounding(false, true)

                            graphNew.gridLabelRenderer.labelFormatter = staticLabelsFormatter
                            graphNew.gridLabelRenderer.setHumanRounding(false, true)
                        }

                        StatsPeriod.MONTH -> {
                            Log.d("IGFlexin_dashboard", "Days Month: " + data.daysOfMonth.size)

                            val dataPoints = ArrayList<DataPoint>()
                            val dataPointsBar = ArrayList<DataPoint>()

                            var minFollowers = Double.MAX_VALUE
                            var maxFollowers = Double.MIN_VALUE

                            if (data.daysOfMonth.indexOf(null) == -1) {
                                var index = 0
                                var previousFollowers = data.daysOfMonth.first()!!.toDouble()

                                data.daysOfMonth.forEach {
                                    if (it!!.toInt().toDouble() < minFollowers) {
                                        minFollowers = it.toInt().toDouble()
                                    }
                                    if (it.toInt().toDouble() > maxFollowers) {
                                        maxFollowers = it.toInt().toDouble()
                                    }
                                    dataPoints.add(DataPoint(index.toDouble(), it.toInt().toDouble()))
                                    dataPointsBar.add(DataPoint(index.toDouble(), it.toInt().toDouble() - previousFollowers))
                                    previousFollowers = it.toInt().toDouble()
                                    index++
                                }
                            } else {
                                val length = data.daysOfMonth.size - data.daysOfMonth.indexOf(null)

                                for (i in 0..(length - 1)) {
                                    dataPoints.add(DataPoint(i.toDouble(), 0.0))
                                    dataPointsBar.add(DataPoint(i.toDouble(), 0.0))
                                }

                                var index = length
                                var previousFollowers = data.daysOfMonth.first()!!.toDouble()

                                data.daysOfMonth.forEach {
                                    if (dataPoints.size == data.daysOfMonth.size) { return@forEach }
                                    if (it!!.toInt().toDouble() < minFollowers) {
                                        minFollowers = it.toInt().toDouble()
                                    }
                                    if (it.toInt().toDouble() > maxFollowers) {
                                        maxFollowers = it.toInt().toDouble()
                                    }
                                    dataPoints.add(DataPoint(index.toDouble(), it.toInt().toDouble()))
                                    dataPointsBar.add(DataPoint(index.toDouble(), it.toInt().toDouble() - previousFollowers))
                                    previousFollowers = it.toInt().toDouble()
                                    index++
                                }
                            }

                            graphTotal.removeAllSeries()
                            graphNew.removeAllSeries()

                            val series = LineGraphSeries<DataPoint>(dataPoints.toTypedArray())
                            val seriesBar = BarGraphSeries<DataPoint>(dataPointsBar.toTypedArray())

                            series.isDrawBackground = true
                            series.color = Color.TRANSPARENT
                            series.backgroundColor = ContextCompat.getColor(requireContext(), R.color.colorAccent)

                            seriesBar.valuesOnTopSize = 30.0f
                            seriesBar.isDrawValuesOnTop = true
                            seriesBar.spacing = 0
                            seriesBar.color = ContextCompat.getColor(requireContext(), R.color.colorAccent)

                            graphTotal.addSeries(series)
                            graphNew.addSeries(seriesBar)

                            graphTotal.viewport.setMinX(0.0)
                            graphTotal.viewport.setMaxX((data.daysOfMonth.size - 1).toDouble())
                            graphTotal.viewport.isXAxisBoundsManual = true

                            graphNew.viewport.setMinX(0.0)
                            graphNew.viewport.setMaxX((data.daysOfMonth.size - 1).toDouble())
                            graphNew.viewport.isXAxisBoundsManual = true

                            if (minFollowers - 5.0 <= 0) {
                                graphTotal.viewport.setMinY(0.0)
                            } else {
                                graphTotal.viewport.setMinY(minFollowers - 5.0)
                            }

                            graphTotal.viewport.setMaxY(maxFollowers + 5.0)
                            graphTotal.viewport.isYAxisBoundsManual = true

                            val staticLabelsFormatter = StaticLabelsFormatter(graphTotal)
                            val format = SimpleDateFormat.getDateTimeInstance()
                            val labels = ArrayList<String>()

                            for (i in 0..(data.daysOfMonth.size - 1)) {
                                when (i) {
                                    0 -> labels.add(format.format(Date(data.lastAction.time - (1000 * 60 * 60 * 24 * 7))))
                                    data.daysOfMonth.size - 1 -> labels.add(format.format(data.lastAction))
                                    else -> labels.add("")
                                }
                            }

                            staticLabelsFormatter.setHorizontalLabels(labels.toTypedArray())

                            graphTotal.gridLabelRenderer.labelFormatter = staticLabelsFormatter
                            graphTotal.gridLabelRenderer.setHumanRounding(false, true)

                            graphNew.gridLabelRenderer.labelFormatter = staticLabelsFormatter
                            graphNew.gridLabelRenderer.setHumanRounding(false, true)
                        }
                    }

                    noDataTextView.visibility = View.GONE
                    scrollView.visibility = View.VISIBLE
                }
                InstagramStatusCode.DATA_EMPTY -> {
                    noDataTextView.visibility = View.VISIBLE
                    scrollView.visibility = View.GONE
                }
            }
        }
    }
}