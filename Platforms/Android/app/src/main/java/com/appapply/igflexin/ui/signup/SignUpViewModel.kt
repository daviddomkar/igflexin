package com.appapply.igflexin.ui.signup

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.appapply.igflexin.codes.StatusCode
import com.appapply.igflexin.events.Event
import com.appapply.igflexin.repositories.AuthRepository

class SignUpViewModel(private val authRepository: AuthRepository) : ViewModel() {
    private val showProgressBarLiveData: MutableLiveData<Boolean> = MutableLiveData()

    fun signUp(name: String, email: String, password: String) {
        authRepository.signUp(name, email, password)
    }

    fun showProgressBar(show: Boolean) {
        showProgressBarLiveData.value = show
    }

    fun getShowProgressBarLiveData(): LiveData<Boolean> {
        return showProgressBarLiveData
    }

    fun getAuthStatusLiveData(): LiveData<Event<StatusCode>> {
        return authRepository.getAuthStatusLiveData()
    }
}
