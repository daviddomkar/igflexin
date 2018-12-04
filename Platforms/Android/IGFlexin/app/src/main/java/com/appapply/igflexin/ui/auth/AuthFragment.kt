package com.appapply.igflexin.ui.auth

import android.os.Bundle
import android.util.Log
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.res.ResourcesCompat
import androidx.lifecycle.Observer
import androidx.navigation.fragment.NavHostFragment
import androidx.navigation.fragment.findNavController
import com.appapply.igflexin.R
import com.appapply.igflexin.common.AuthStatusCode
import com.appapply.igflexin.common.OnBackPressedFinishListener
import com.appapply.igflexin.common.StatusCode
import com.appapply.igflexin.events.EventObserver
import com.appapply.igflexin.ui.auth.verifyemail.VerifyEmailFragment
import com.google.android.material.snackbar.Snackbar
import kotlinx.android.synthetic.main.auth_fragment.*
import org.koin.androidx.viewmodel.ext.android.sharedViewModel

class AuthFragment : Fragment(), OnBackPressedFinishListener {

    private val viewModel: AuthViewModel by sharedViewModel()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.auth_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        Log.d("IGFlexin_navigation", "AuthFragment onActivityCreated")

        viewModel.userLiveData.observe(this, Observer {

            // Check if we have information about the user else display auth navigation
            if (it.status == StatusCode.SUCCESS) {

                // Check if user has verified his email and popBack else show email verificationFragment
                if (it.data != null && !it.data.emailVerified) {
                    if (childFragmentManager.fragments.size > 0) {
                        if (childFragmentManager.fragments[0] is NavHostFragment) {
                            val verifyEmailFragment = VerifyEmailFragment()
                            childFragmentManager.beginTransaction().replace(R.id.authFrameLayout, verifyEmailFragment).commit()
                        }
                    } else {
                        viewModel.showProgressBar(false)
                        val verifyEmailFragment = VerifyEmailFragment()
                        childFragmentManager.beginTransaction().add(R.id.authFrameLayout, verifyEmailFragment).commit()
                    }
                } else {
                    Log.d("IGFlexin_auth", "Navigating back to LoaderFragment")
                    viewModel.userLiveData.removeObservers(this)
                    findNavController().popBackStack()
                }
            } else {
                if (childFragmentManager.fragments.size > 0) {
                    if (childFragmentManager.fragments[0] is VerifyEmailFragment) {
                        viewModel.showProgressBar(false)
                        viewModel.displayLogin = true
                        val navHostFragment = NavHostFragment.create(R.navigation.auth_navigation)
                        childFragmentManager.beginTransaction().setCustomAnimations(R.anim.fade_in, R.anim.fade_out, R.anim.fade_in, R.anim.fade_out).replace(R.id.authFrameLayout, navHostFragment).commit()
                    }
                } else {
                    viewModel.showProgressBar(false)
                    val navHostFragment = NavHostFragment.create(R.navigation.auth_navigation)
                    childFragmentManager.beginTransaction().add(R.id.authFrameLayout, navHostFragment).commit()
                }
            }
        })

        viewModel.authErrorLiveData.observe(this, EventObserver {
            when(it) {
                StatusCode.ERROR -> {
                    viewModel.snack(getString(R.string.error_occurred))
                }
                StatusCode.NETWORK_ERROR -> {
                    viewModel.snack(getString(R.string.error_check_your_connection))
                }
                AuthStatusCode.USER_NOT_FOUND -> {
                    viewModel.snack(getString(R.string.account_not_found))
                }
                AuthStatusCode.USER_DISABLED -> {
                    viewModel.snack(getString(R.string.account_already_exists))
                }
                AuthStatusCode.EMAIL_ALREADY_IN_USE -> {
                    viewModel.snack(getString(R.string.account_already_exists))
                }
                AuthStatusCode.EXISTS_WITH_DIFFERENT_CREDENTIAL -> {
                    viewModel.snack(getString(R.string.account_exists_with_different_auth_method))
                }
                AuthStatusCode.CREDENTIAL_ALREADY_IN_USE -> {
                    viewModel.snack(getString(R.string.account_auth_credential_link_to_another_account))
                }
                AuthStatusCode.INVALID_CREDENTIALS -> {
                    viewModel.snack(getString(R.string.invalid_password))
                }
                AuthStatusCode.WEAK_PASSWORD -> {
                    viewModel.snack(getString(R.string.weak_password))
                }
            }

            viewModel.showProgressBar(false, true)
        })

        viewModel.showProgressBarLiveData.observe(this, Observer {
            if (it.first) {
                if (it.second) {
                    progressBarHolder.alpha = 1.0f
                    progressBarHolder.visibility = View.VISIBLE
                } else {
                    progressBarHolder.visibility = View.VISIBLE
                    progressBarHolder.animate().setDuration(200).alpha(1.0f).start()
                }
            } else {
                if (it.second) {
                    progressBarHolder.alpha = 0.0f
                    progressBarHolder.visibility = View.GONE
                } else {
                    progressBarHolder.animate().setDuration(200).alpha(0.0f).withEndAction {
                        progressBarHolder.visibility = View.GONE
                    }.start()
                }
            }
        })

        viewModel.snackLiveData.observe(this, EventObserver {
            val snackbar = Snackbar.make(holderLayout, it, Snackbar.LENGTH_SHORT)
            snackbar.view.setBackgroundColor(ResourcesCompat.getColor(resources, R.color.colorPrimary, null))
            snackbar.show()
        })

        // TODO add spannable links
    }

    override fun onBackPressed(): Boolean {
        if (viewModel.loading) { return true }

        val currentFragment = childFragmentManager.fragments[0]

        /*
        if (currentFragment is NavHostFragment && currentFragment.childFragmentManager.fragments[0] is OnBackPressedListener && (currentFragment.childFragmentManager.fragments[0] as OnBackPressedListener).onBackPressed()) {
            return true
        }*/

        // Don't know what this does already xd - but it works and that's important
        return !((currentFragment is NavHostFragment && !currentFragment.navController.popBackStack()) || currentFragment is VerifyEmailFragment)
    }
}
