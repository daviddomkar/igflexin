package com.appapply.igflexin.ui.dashboard

import androidx.lifecycle.ViewModel
import com.appapply.igflexin.repositories.AuthRepository

class DashboardViewModel(private val authRepository: AuthRepository) : ViewModel() {

    fun signOut() {
        authRepository.signOut()
    }

}
