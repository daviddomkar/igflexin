package com.appapply.igflexin.ui.emailverification

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.appapply.igflexin.codes.StatusCode
import com.appapply.igflexin.repositories.AuthRepository

class EmailVerificationViewModel(private val authRepository: AuthRepository) : ViewModel() {
    private val showProgressBarLiveData: MutableLiveData<Boolean> = MutableLiveData()

    fun sendVerificationEmail() {
        authRepository.sendVerificationEmail()
    }

    fun showProgressBar(show: Boolean) {
        showProgressBarLiveData.value = show
    }

    fun signOut() {
        authRepository.signOut()
    }

    fun getShowProgressBarLiveData(): LiveData<Boolean> {
        return showProgressBarLiveData
    }

    fun getSignedInLiveData() : LiveData<Boolean> {
        return authRepository.getSignedInLiveData()
    }

    fun getEmailVerificationStatusLiveData() : LiveData<StatusCode> {
        return authRepository.getVerificationEmailStatusLiveData()
    }
}
