package com.appapply.igflexin.ui.auth.verifyemail

import android.os.Bundle
import android.util.Log
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup

import com.appapply.igflexin.R
import com.appapply.igflexin.common.StatusCode
import com.appapply.igflexin.events.EventObserver
import com.appapply.igflexin.ui.auth.AuthViewModel
import kotlinx.android.synthetic.main.verify_email_fragment.*
import org.koin.androidx.viewmodel.ext.android.sharedViewModel
import org.koin.androidx.viewmodel.ext.android.viewModel

class VerifyEmailFragment : Fragment() {

    private val viewModel: VerifyEmailViewModel by viewModel()
    private val authViewModel: AuthViewModel by sharedViewModel()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.verify_email_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        Log.d("IGFlexin_navigation", "VerifyEmailFragment onActivityCreated")

        viewModel.emailSentStatusLiveData.observe(this, EventObserver {
            when (it) {
                StatusCode.PENDING -> authViewModel.showProgressBar(true)
                StatusCode.SUCCESS -> {
                    Log.d("IGFlexin_auth", "Email sent successfully")

                    viewModel.activationEmailSent = true

                    descriptionTextView.text = getString(R.string.verification_link_has_been_sent_to_your_email_activate_your_account_and_go_back_to_the_app_to_sign_in)
                    logInOrRetryButton.text = getString(R.string.log_in)
                    logInOrRetryButton.setOnClickListener {
                        viewModel.signOut()
                    }

                    authViewModel.showProgressBar(false)
                }
                StatusCode.NETWORK_ERROR -> {
                    Log.d("IGFlexin_auth", "Email network error")

                    viewModel.activationEmailSent = false

                    descriptionTextView.text = getString(R.string.sending_verification_email_failed_no_connection)
                    logInOrRetryButton.text = getString(R.string.try_again)
                    logInOrRetryButton.setOnClickListener {
                        viewModel.sendVerificationEmail()
                    }

                    authViewModel.showProgressBar(false)
                }
                StatusCode.ERROR -> {
                    Log.d("IGFlexin_auth", "Email error")

                    viewModel.activationEmailSent = false

                    descriptionTextView.text = getString(R.string.sending_verification_email_failed)
                    logInOrRetryButton.text = getString(R.string.try_again)
                    logInOrRetryButton.setOnClickListener {
                        viewModel.sendVerificationEmail()
                    }

                    authViewModel.showProgressBar(false)
                }
            }
        })
    }

}
