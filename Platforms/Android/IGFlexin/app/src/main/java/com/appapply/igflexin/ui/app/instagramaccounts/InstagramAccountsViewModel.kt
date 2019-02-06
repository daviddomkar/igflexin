package com.appapply.igflexin.ui.app.instagramaccounts

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.appapply.igflexin.model.InstagramAccount
import com.appapply.igflexin.repository.ConnectionRepository
import com.appapply.igflexin.repository.InstagramRepository

class InstagramAccountsViewModel(private val instagramRepository: InstagramRepository, private val connectionRepository: ConnectionRepository) : ViewModel() {
    private val showErrorLayoutMutableLiveData: MutableLiveData<Boolean> = MutableLiveData()

    val connectionLiveData = connectionRepository.connectionLiveData
    val showErrorLayoutLiveData: LiveData<Boolean> = showErrorLayoutMutableLiveData
    val addInstagramAccountStatusLiveData = instagramRepository.addInstagramAccountStatusLiveData
    val editInstagramAccountStatusLiveData = instagramRepository.editInstagramAccountStatusLiveData

    fun showErrorLayout(show: Boolean) {
        showErrorLayoutMutableLiveData.value = show
    }

    fun addInstagramAccount(nick: String, password: String, subscriptionID: String) {
        instagramRepository.addInstagramAccount(nick, password, subscriptionID)
    }

    fun editInstagramUsername(id: Long, username: String) {
        instagramRepository.editInstagramUsername(id, username)
    }

    fun editInstagramPassword(id: Long, password: String) {
        instagramRepository.editInstagramPassword(id, password)
    }

    fun pauseInstagramAccount(id: Long) {
        instagramRepository.pauseInstagramAccount(id)
    }

    fun resetInstagramAccount(id: Long) {
        instagramRepository.resetInstagramAccount(id)
    }

    fun deleteInstagramAccount(id: Long) {
        instagramRepository.deleteInstagramAccount(id)
    }

    fun updateAccountWorkers(accounts: Iterable<InstagramAccount>) {
        instagramRepository.updateAccountWorkers(accounts)
    }

    override fun onCleared() {
        super.onCleared()
        instagramRepository.reset()
    }
}
