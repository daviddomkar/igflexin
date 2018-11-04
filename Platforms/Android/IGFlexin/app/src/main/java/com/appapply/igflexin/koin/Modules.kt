package com.appapply.igflexin.koin

import com.appapply.igflexin.repository.TestUserRepository
import com.appapply.igflexin.repository.UserRepository
import com.appapply.igflexin.ui.app.AppViewModel
import com.appapply.igflexin.ui.auth.AuthViewModel
import com.appapply.igflexin.ui.loader.LoaderViewModel
import com.appapply.igflexin.ui.subscription.SubscriptionViewModel
import org.koin.androidx.viewmodel.ext.koin.viewModel
import org.koin.dsl.module.module

val appModule = module {

    single<UserRepository> { TestUserRepository() }

    viewModel { LoaderViewModel(get()) }
    viewModel { AuthViewModel(get()) }
    viewModel { SubscriptionViewModel() }
    viewModel { AppViewModel() }
}

val modules = listOf(appModule)