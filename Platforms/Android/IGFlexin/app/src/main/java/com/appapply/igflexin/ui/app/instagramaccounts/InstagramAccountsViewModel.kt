package com.appapply.igflexin.ui.app.instagramaccounts

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.appapply.igflexin.model.InstagramAccountInfo
import com.appapply.igflexin.repository.ConnectionRepository
import com.appapply.igflexin.repository.InstagramRepository

class InstagramAccountsViewModel(private val instagramRepository: InstagramRepository, private val connectionRepository: ConnectionRepository) : ViewModel() {
    private val showErrorLayoutMutableLiveData: MutableLiveData<Boolean> = MutableLiveData()

    val connectionLiveData = connectionRepository.connectionLiveData
    val showErrorLayoutLiveData: LiveData<Boolean> = showErrorLayoutMutableLiveData
    val addInstagramAccountStatusLiveData = instagramRepository.addInstagramAccountStatusLiveData

    fun showErrorLayout(show: Boolean) {
        showErrorLayoutMutableLiveData.value = show
    }

    fun addInstagramAccount(nick: String, password: String, subscriptionID: String) {
        instagramRepository.addInstagramAccount(nick, password, subscriptionID)
    }

    fun editInstagramAccount(username: String, password: String) {
        instagramRepository.editInstagramAccount(username, password)
    }

    fun deleteInstagramAccount(username: String) {
        instagramRepository.deleteInstagramAccount(username)
    }

    fun getInstagramAccountInfo(username: String, encryptedPassword: String, onSuccess: (info: InstagramAccountInfo) -> Unit, onError: () -> Unit) {
        instagramRepository.getInstagramAccountInfo(username, encryptedPassword, onSuccess, onError)
    }

    override fun onCleared() {
        super.onCleared()
        instagramRepository.reset()
    }
}
