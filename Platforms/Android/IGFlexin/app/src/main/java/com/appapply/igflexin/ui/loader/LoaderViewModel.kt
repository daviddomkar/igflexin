package com.appapply.igflexin.ui.loader

import androidx.lifecycle.ViewModel
import com.appapply.igflexin.repository.UserRepository

class LoaderViewModel(private val userRepository: UserRepository) : ViewModel() {
    val userLiveData = userRepository.userLiveData
}
