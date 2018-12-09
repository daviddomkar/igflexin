package com.appapply.igflexin.ui.app.instagramaccounts

import androidx.lifecycle.ViewModel
import com.appapply.igflexin.repository.InstagramRepository

class InstagramAccountsViewModel(private val instagramRepository: InstagramRepository) : ViewModel() {
    val addInstagramAccountStatusLiveData = instagramRepository.addInstagramAccountStatusLiveData


    fun addInstagramAccount(nick: String, password: String, subscriptionID: String) {

        instagramRepository.addInstagramAccount(nick, password, subscriptionID)
    }

    override fun onCleared() {
        super.onCleared()
        instagramRepository.reset()
    }
}
