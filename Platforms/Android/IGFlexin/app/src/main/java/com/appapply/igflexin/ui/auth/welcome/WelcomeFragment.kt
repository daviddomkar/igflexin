package com.appapply.igflexin.ui.auth.welcome

import android.os.Bundle
import android.text.SpannableString
import android.text.Spanned
import android.text.TextPaint
import android.text.method.LinkMovementMethod
import android.text.style.ClickableSpan
import android.util.Log
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.res.ResourcesCompat
import androidx.navigation.fragment.findNavController
import com.appapply.igflexin.MainViewModel
import com.appapply.igflexin.R
import com.appapply.igflexin.common.Resource
import com.appapply.igflexin.common.StartActivityForResultObject
import com.appapply.igflexin.common.StatusCode
import com.appapply.igflexin.events.EventObserver
import com.appapply.igflexin.ui.auth.AuthViewModel
import com.google.firebase.auth.AuthCredential
import kotlinx.android.synthetic.main.welcome_fragment.*
import org.koin.androidx.viewmodel.ext.android.sharedViewModel
import org.koin.androidx.viewmodel.ext.android.viewModel
import android.content.Intent
import android.net.Uri
import java.lang.Exception

class WelcomeFragment : Fragment() {

    private val viewModel: WelcomeViewModel by viewModel()
    private val authViewModel: AuthViewModel by sharedViewModel()
    private val mainViewModel: MainViewModel by sharedViewModel()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.welcome_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        Log.d("IGFlexin_navigation", "WelcomeFragment onActivityCreated")

        if (authViewModel.displayLogin) {
            authViewModel.displayLogin = false
            Log.d("IGFlexin_navigation", "display login")
            findNavController().navigate(R.id.action_welcomeFragment_to_logInFragment)
            return
        }

        logInButton.setOnClickListener {
            findNavController().navigate(R.id.action_welcomeFragment_to_logInFragment)
        }

        signUpButton.setOnClickListener {
            findNavController().navigate(R.id.action_welcomeFragment_to_signUpFragment)
        }

        googleSignInButton.setOnClickListener {
            startSignInGoogle()
        }

        facebookSignInButton.setOnClickListener {
            startSignInFacebook()
        }

        mainViewModel.onActivityResultObjectLiveData.observe(this, EventObserver {
            if (it.requestCode == 1000) {
                continueSignIn(viewModel.getGoogleAuthCredential(it.data!!))
            }

            viewModel.onActivityResult(it)
        })

        viewModel.facebookAuthCredentialLiveData.observe(this, EventObserver {
            continueSignIn(it)
        })

        setupClickableLinks()
    }

    private fun setupClickableLinks() {
        val howItWorksSpannableString = SpannableString(getString(R.string.how_it_works_see_for_yourself))
        val howItWorksClickableSpan = object : ClickableSpan() {
            override fun onClick(textView: View) {
                // TODO How it works
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
                try {
                    startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://igflexin.app/privacy-policy.htm")))
                } catch (e: Exception) {}
            }

            override fun updateDrawState(textPaint: TextPaint) {
                super.updateDrawState(textPaint)
                textPaint.isUnderlineText = true
            }
        }
        acceptingTermsSpannableString.setSpan(acceptingTermsClickableSpan, 43, 58, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)

        acceptingTermsTextView.text = acceptingTermsSpannableString
        acceptingTermsTextView.movementMethod = LinkMovementMethod.getInstance()
        acceptingTermsTextView.highlightColor = ResourcesCompat.getColor(resources, R.color.colorAccent, null)
    }

    private fun startSignInGoogle() {
        authViewModel.showProgressBar(true)
        mainViewModel.startActivityForResult(StartActivityForResultObject(authViewModel.getGoogleSignInIntent(), 1000))
    }

    private fun continueSignIn(authCredential: Resource<AuthCredential>) {
        when (authCredential.status) {
            StatusCode.SUCCESS -> viewModel.signInWithCredential(authCredential.data!!)
            StatusCode.NETWORK_ERROR -> {
                authViewModel.showProgressBar(false)
                authViewModel.snack(getString(R.string.error_check_your_connection))
            }
            StatusCode.CANCELED -> {
                authViewModel.showProgressBar(false)
            }
            StatusCode.ERROR -> {
                authViewModel.showProgressBar(false)
                authViewModel.snack(getString(R.string.error_occurred))
            }
        }
    }

    private fun startSignInFacebook() {
        authViewModel.showProgressBar(true)
        viewModel.signInFacebook(requireActivity())
    }
}
