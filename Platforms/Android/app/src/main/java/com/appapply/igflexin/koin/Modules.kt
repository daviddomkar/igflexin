package com.appapply.igflexin.koin

import com.appapply.igflexin.MainActivityViewModel
import com.appapply.igflexin.R
import com.appapply.igflexin.repositories.*
import com.appapply.igflexin.ui.dashboard.DashboardViewModel
import com.appapply.igflexin.ui.welcomescreen.WelcomeScreenViewModel
import com.facebook.CallbackManager
import com.facebook.login.LoginManager
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInOptions

import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import org.koin.android.ext.koin.androidContext

import org.koin.androidx.viewmodel.ext.koin.viewModel
import org.koin.dsl.module.module

val appModule = module {

    single<AuthRepository> { FirebaseAuthRepository(get()) }

    viewModel { MainActivityViewModel(get()) }
    viewModel { DashboardViewModel(get()) }
    viewModel { WelcomeScreenViewModel(get(), get(), get()) }
}

val firebaseModule = module {
    single { FirebaseAuth.getInstance() }
    single { FirebaseFirestore.getInstance() }
}

val googleModule = module {
    single { GoogleSignIn.getClient(androidContext(), GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN).requestIdToken(androidContext().resources.getString(R.string.default_web_client_id)).requestEmail().build()) }
    single<GoogleSignInRepository> { GoogleSignInRepositoryImpl(get()) }
}

val facebookModule = module {
    single { CallbackManager.Factory.create() }
    single { LoginManager.getInstance() }
    single<FacebookRepository> { FacebookRepositoryImpl(get(), get()) }
}

val allModules = listOf(appModule, firebaseModule, googleModule, facebookModule)