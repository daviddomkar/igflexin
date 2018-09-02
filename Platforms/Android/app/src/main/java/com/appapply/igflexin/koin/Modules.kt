package com.appapply.igflexin.koin

import com.appapply.igflexin.repositories.FirebaseUserRepository
import com.appapply.igflexin.repositories.UserRepository
import com.appapply.igflexin.ui.dashboard.DashboardViewModel

import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore

import org.koin.android.viewmodel.ext.koin.viewModel
import org.koin.dsl.module.module

val appModule = module {

    single<UserRepository> { FirebaseUserRepository() }

    //viewModel { DashboardViewModel(get()) }
}

val firebaseModule = module {
    single { FirebaseAuth.getInstance() }
    single { FirebaseFirestore.getInstance() }
}

val allModules = listOf(appModule, firebaseModule)