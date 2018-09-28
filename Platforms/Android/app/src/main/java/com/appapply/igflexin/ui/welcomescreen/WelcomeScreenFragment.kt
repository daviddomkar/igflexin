package com.appapply.igflexin.ui.welcomescreen

import android.os.Bundle
import android.text.SpannableString
import android.text.Spanned
import android.text.TextPaint
import android.text.method.LinkMovementMethod
import android.text.style.ClickableSpan
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.res.ResourcesCompat
import androidx.lifecycle.Observer
import androidx.navigation.fragment.findNavController
import com.appapply.igflexin.MainActivityViewModel
import com.appapply.igflexin.R
import com.appapply.igflexin.codes.AuthStatusCode
import com.appapply.igflexin.codes.StatusCode
import com.appapply.igflexin.events.EventObserver
import com.appapply.igflexin.pojo.StartActivityForResultCall
import kotlinx.android.synthetic.main.welcome_screen_fragment.*
import org.koin.androidx.viewmodel.ext.android.sharedViewModel

import org.koin.androidx.viewmodel.ext.android.viewModel

class WelcomeScreenFragment : Fragment() {

    private val mainActivityViewModel: MainActivityViewModel by sharedViewModel()
    private val welcomeScreenViewModel: WelcomeScreenViewModel by viewModel()

    private var uiDisabled: Boolean = false

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.welcome_screen_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        welcomeScreenViewModel.init()

        mainActivityViewModel.onActivityResultCall().observe(this, EventObserver { onActivityResultCall ->
            if(onActivityResultCall.requestCode == 1000) {
                welcomeScreenViewModel.getGoogleCredentialLiveData(onActivityResultCall.data!!).observe(this, EventObserver {
                    welcomeScreenViewModel.applyCredential(it)
                })
            }

            welcomeScreenViewModel.aquireActivityResult(onActivityResultCall)
        })

        welcomeScreenViewModel.getAuthStatusLiveData().observe(this, EventObserver {
            handleAuthStatus(it)
        })

        welcomeScreenViewModel.getGoogleCredentialStatusLiveData().observe(this, EventObserver {
            handleCredentialStatus(it)
        })

        welcomeScreenViewModel.getFacebookCredentialLiveData().observe(this, EventObserver {
            welcomeScreenViewModel.applyCredential(it)
        })

        welcomeScreenViewModel.getFacebookCredentialStatusLiveData().observe(this, EventObserver {
            handleCredentialStatus(it)
        })
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        welcomeScreenViewModel.getShowProgressBarLiveData().observe(this, Observer {
            if (it.first) {
                progressBarHolder.visibility = View.VISIBLE
                progressBarHolder.animate().setDuration(200).alpha(1.0f).start()
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

        //Setup buttons
        signInButton.setOnClickListener {
            findNavController().navigate(R.id.action_welcomeScreenFragment_to_signInFragment)
        }

        signInOrRetryButton.setOnClickListener {
            findNavController().navigate(R.id.action_welcomeScreenFragment_to_signUpFragment)
        }

        googleSignInButton.setOnClickListener { _ ->
            showLoading(true, false)
            welcomeScreenViewModel.getGoogleSignInSignInIntentLiveData().observe(this, EventObserver {
                mainActivityViewModel.sendStartActivityForResultCall(StartActivityForResultCall(it, 1000))
            })
        }

        facebookSignInButton.setOnClickListener {
            showLoading(true, false)
            welcomeScreenViewModel.continueWithFacebook(requireActivity())
        }

        //Setup clickable links
        setupClickableLinks()
    }

    private fun setupClickableLinks() {
        val howItWorksSpannableString = SpannableString(getString(R.string.how_it_works_see_for_yourself))
        val howItWorksClickableSpan = object : ClickableSpan() {
            override fun onClick(textView: View) {
                if(!uiDisabled)
                    findNavController().navigate(R.id.action_welcomeScreenFragment_to_howItWorksFragment)
            }

            override fun updateDrawState(textPaint: TextPaint) {
                super.updateDrawState(textPaint)
                textPaint.isUnderlineText = true
            }
        }
        howItWorksSpannableString.setSpan(howItWorksClickableSpan, 14, 31, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)

        howItWorksTextView.text = howItWorksSpannableString
        howItWorksTextView.movementMethod = LinkMovementMethod.getInstance()
        howItWorksTextView.highlightColor = ResourcesCompat.getColor(resources, R.color.colorAccent, null)

        val acceptingTermsSpannableString = SpannableString(getString(R.string.by_creating_an_account_i_accept_igflexin_s_terms_of_service))
        val acceptingTermsClickableSpan = object : ClickableSpan() {
            override fun onClick(textView: View) {
                if(!uiDisabled) {
                    // TODO do something
                }
            }

            override fun updateDrawState(textPaint: TextPaint) {
                super.updateDrawState(textPaint)
                textPaint.isUnderlineText = true
            }
        }
        acceptingTermsSpannableString.setSpan(acceptingTermsClickableSpan, 43, 60, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)

        acceptingTermsTextView.text = acceptingTermsSpannableString
        acceptingTermsTextView.movementMethod = LinkMovementMethod.getInstance()
        acceptingTermsTextView.highlightColor = ResourcesCompat.getColor(resources, R.color.colorAccent, null)
    }

    private fun showLoading(show: Boolean, explicit: Boolean) {
        welcomeScreenViewModel.showProgressBar(show, explicit)
    }

    private fun handleAuthStatus(authStatusCode: StatusCode) {
        if(authStatusCode != StatusCode.SUCCESS) {
            showLoading(false, false)
        }

        when(authStatusCode) {
            StatusCode.SUCCESS -> {
                showLoading(false, true)
            }
            StatusCode.CANCELED -> {
                return
            }
            StatusCode.ERROR -> {
                mainActivityViewModel.snack(getString(R.string.error_occurred))
            }
            AuthStatusCode.USER_NOT_FOUND -> {
                mainActivityViewModel.snack(getString(R.string.account_not_found))
            }
            AuthStatusCode.USER_DISABLED -> {
                mainActivityViewModel.snack(getString(R.string.account_already_exists))
            }
            AuthStatusCode.EMAIL_ALREADY_IN_USE -> {
                mainActivityViewModel.snack(getString(R.string.account_already_exists))
            }
            AuthStatusCode.EXISTS_WITH_DIFFERENT_CREDENTIAL -> {
                mainActivityViewModel.snack(getString(R.string.account_exists_with_different_auth_method))
            }
            AuthStatusCode.CREDENTIAL_ALREADY_IN_USE -> {
                mainActivityViewModel.snack(getString(R.string.account_auth_credential_link_to_another_account))
            }
            AuthStatusCode.INVALID_CREDENTIALS -> {
                mainActivityViewModel.snack(getString(R.string.invalid_password))
            }
            AuthStatusCode.WEAK_PASSWORD -> {
                mainActivityViewModel.snack(getString(R.string.weak_password))
            }
        }
    }

    private fun handleCredentialStatus(credentialStatusCode: StatusCode) {
        when (credentialStatusCode) {
            StatusCode.SUCCESS -> {
                return
            }
            StatusCode.NETWORK_ERROR -> {
                showLoading(false, false)
                mainActivityViewModel.snack(getString(R.string.error_check_your_connection))
            }
            StatusCode.CANCELED -> {
                showLoading(false, false)
            }
            StatusCode.ERROR -> {
                showLoading(false, false)
                mainActivityViewModel.snack(getString(R.string.error_occurred))
            }
        }
    }
}
