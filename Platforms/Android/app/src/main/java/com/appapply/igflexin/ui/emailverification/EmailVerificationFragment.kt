package com.appapply.igflexin.ui.emailverification

import android.os.Bundle
import android.util.Log.d
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.Observer
import androidx.navigation.fragment.findNavController
import com.appapply.igflexin.MainActivityViewModel

import com.appapply.igflexin.R
import com.appapply.igflexin.codes.StatusCode
import kotlinx.android.synthetic.main.email_verification_fragment.*
import org.koin.androidx.viewmodel.ext.android.sharedViewModel
import org.koin.androidx.viewmodel.ext.android.viewModel

class EmailVerificationFragment : Fragment() {

    private val mainActivityViewModel: MainActivityViewModel by sharedViewModel()
    private val emailVerificationViewModel: EmailVerificationViewModel by viewModel()

    private var emailSent = false

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.email_verification_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        emailSent = false

        d("IGFlexin", "Jejda")

        mainActivityViewModel.disableBackNavigation(true)

        emailVerificationViewModel.getSignedInLiveData().observe(this, Observer {
            if(!it) {
                findNavController().popBackStack(R.id.welcomeScreenFragment, false)
            } else {
                if(!emailSent) {
                    emailVerificationViewModel.sendVerificationEmail()
                }
            }
        })

        emailVerificationViewModel.getEmailVerificationStatusLiveData().observe(this, Observer { statusCode ->
            when (statusCode) {
                StatusCode.SUCCESS -> {
                    showLoading(false)
                    descriptionTextView.text = getString(R.string.verification_link_has_been_sent_to_your_email_activate_your_account_and_go_back_to_the_app_to_sign_in)
                    signInOrRetryButton.text = getString(R.string.sign_in)
                    signInOrRetryButton.setOnClickListener {
                        mainActivityViewModel.disableBackNavigation(false)
                        emailVerificationViewModel.signOut()
                        findNavController().popBackStack(R.id.dashboardFragment, false)
                    }
                    emailSent = true
                }
                StatusCode.PENDING -> {
                    showLoading(true)
                }
                StatusCode.ERROR -> {
                    showLoading(false)
                    descriptionTextView.text = getString(R.string.sending_verification_email_failed)
                    signInOrRetryButton.text = getString(R.string.try_again)
                    signInOrRetryButton.setOnClickListener {
                        emailVerificationViewModel.sendVerificationEmail()
                    }
                }
            }
        })
    }

    private fun showLoading(show: Boolean) {
        mainActivityViewModel.showProgressBar(show, false)
    }
}
