package com.appapply.igflexin.ui.app.dashboard

import android.util.Log
import androidx.lifecycle.ViewModel
import com.appapply.igflexin.repository.InstagramRepository

class DashboardViewModel(private val instagramRepository: InstagramRepository) : ViewModel() {

    val instagramAccountsLiveData = instagramRepository.instagramAccountsLiveData
    val instagramRecordsLiveData = instagramRepository.instagramRecordsLiveData

    var id: Long = -1
    var period = -1

    fun setStatsID(id: Long) {
        Log.d("IGFlexin_dashboard", "Stats will load for id: $id")
        this.id = id
        updateRecordsIDAndPeriod()
    }

    fun setStatsPeriod(period: Int) {
        Log.d("IGFlexin_dashboard", "Stats will load for period: $period")
        this.period = period
        updateRecordsIDAndPeriod()
    }

    private fun updateRecordsIDAndPeriod() {
        instagramRepository.setRecordsIDAndPeriod(this.id, this.period)
    }
}
