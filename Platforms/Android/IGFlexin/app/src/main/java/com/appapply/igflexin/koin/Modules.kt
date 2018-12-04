package com.appapply.igflexin.koin

import com.appapply.igflexin.MainViewModel
import com.appapply.igflexin.R
import com.appapply.igflexin.billing.BillingManager
import com.appapply.igflexin.livedata.firebase.FirebaseAuthStateLiveData
import com.appapply.igflexin.repository.*
import com.appapply.igflexin.ui.app.AppViewModel
import com.appapply.igflexin.ui.app.subscriptionmanagement.SubscriptionManagementViewModel
import com.appapply.igflexin.ui.app.subscriptionmanagement.subscriptiontab.SubscriptionTabViewModel
import com.appapply.igflexin.ui.auth.AuthViewModel
import com.appapply.igflexin.ui.auth.login.LogInViewModel
import com.appapply.igflexin.ui.auth.signup.SignUpViewModel
import com.appapply.igflexin.ui.auth.verifyemail.VerifyEmailViewModel
import com.appapply.igflexin.ui.auth.welcome.WelcomeViewModel
import com.appapply.igflexin.ui.loader.LoaderViewModel
import com.appapply.igflexin.ui.subscription.SubscriptionViewModel
import com.appapply.igflexin.ui.subscription.bundle.BundleFragment
import com.appapply.igflexin.ui.subscription.bundle.BundleViewModel
import com.appapply.igflexin.ui.subscription.period.PeriodFragment
import com.appapply.igflexin.ui.subscription.period.PeriodViewModel
import com.facebook.CallbackManager
import com.facebook.login.LoginManager
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.functions.FirebaseFunctions
import org.koin.android.ext.koin.androidContext
import org.koin.androidx.viewmodel.ext.koin.viewModel
import org.koin.dsl.module.module

val appModule = module {

    single { BillingManager(androidContext()) }

    single<AuthRepository> { FirebaseAuthRepository(get(), get()) }
    single<UserRepository> { FirebaseUserRepository(get()) }
    single<SubscriptionRepository> { FirebaseSubscriptionRepository(get(), get(), get(), get()) }

    viewModel { MainViewModel() }

    viewModel { LoaderViewModel(get(), get()) }

    viewModel { AuthViewModel(get(), get(), get()) }
    viewModel { WelcomeViewModel(get(), get(), get()) }
    viewModel { LogInViewModel(get()) }
    viewModel { SignUpViewModel(get()) }
    viewModel { VerifyEmailViewModel(get()) }

    viewModel { SubscriptionViewModel(get(), get()) }
    viewModel { PeriodViewModel(get()) }
    viewModel { BundleViewModel(get()) }

    viewModel { AppViewModel(get(), get(), get()) }

    viewModel { SubscriptionManagementViewModel() }
    viewModel { SubscriptionTabViewModel() }
}

val firebaseModule = module {

    single { FirebaseFunctions.getInstance() }

    single { FirebaseAuth.getInstance() }

    single { FirebaseFirestore.getInstance() }

    single { FirebaseAuthStateLiveData() }
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

val modules = listOf(firebaseModule, googleModule, facebookModule, appModule)