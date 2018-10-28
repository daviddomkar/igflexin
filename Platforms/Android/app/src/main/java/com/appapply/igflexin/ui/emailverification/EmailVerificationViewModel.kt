package com.appapply.igflexin.ui.emailverification

import androidx.lifecycle.LiveData
import androidx.lifecycle.Transformations
import androidx.lifecycle.ViewModel
import com.appapply.igflexin.codes.StatusCode
import com.appapply.igflexin.repositories.AuthRepository
import com.appapply.igflexin.repositories.UserRepository

class EmailVerificationViewModel(private val authRepository: AuthRepository, private val userRepository: UserRepository) : ViewModel() {
    private val signedInLiveData = Transformations.map(userRepository.getUserLiveData()) { user -> user.uid != null}
    private val verificationEmailStatusLiveData = authRepository.getVerificationEmailStatusLiveData()

    fun sendVerificationEmail() {
        authRepository.sendVerificationEmail()
    }

    fun signOut() {
        authRepository.signOut()
    }

    fun getSignedInLiveData() : LiveData<Boolean> {
        return signedInLiveData
    }

    fun getEmailVerificationStatusLiveData() : LiveData<StatusCode> {
        return verificationEmailStatusLiveData
    }
}
