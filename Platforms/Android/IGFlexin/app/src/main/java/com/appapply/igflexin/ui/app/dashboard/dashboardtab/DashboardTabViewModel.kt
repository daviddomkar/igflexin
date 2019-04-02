package com.appapply.igflexin.ui.app.dashboard.dashboardtab

import androidx.lifecycle.ViewModel
import com.appapply.igflexin.repository.InstagramRepository

class DashboardTabViewModel(private val instagramRepository: InstagramRepository) : ViewModel() {
    val instagramStatisticsLiveData = instagramRepository.instagramStatisticsLiveData

    var period = -1
}
