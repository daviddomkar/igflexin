package com.appapply.igflexin.ui.app.dashboard

import androidx.lifecycle.ViewModel
import com.appapply.igflexin.repository.InstagramRepository

class DashboardViewModel(private val instagramRepository: InstagramRepository) : ViewModel() {

    val instagramAccountsLiveData = instagramRepository.instagramAccountsLiveData
    val instagramStatisticsLiveData = instagramRepository.instagramStatisticsLiveData

    fun setStatsID(id: Long) {
        instagramRepository.setStatsID(id)
    }
}
