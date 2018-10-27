package com.appapply.igflexin.ui.loading

import androidx.lifecycle.ViewModel
import com.appapply.igflexin.repositories.AuthRepository
import com.appapply.igflexin.repositories.SubscriptionRepository
import com.appapply.igflexin.repositories.UserRepository

class LoadingViewModel(private val authRepository: AuthRepository, private val userRepository: UserRepository, private val subscriptionRepository: SubscriptionRepository) : ViewModel() {

}
