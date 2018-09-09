package com.appapply.igflexin.ui.emailverification

import android.os.Bundle
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

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.email_verification_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        mainActivityViewModel.disableBackNavigation(true)

        emailVerificationViewModel.getSignedInLiveData().observe(this, Observer {
            if(!it) {
                findNavController().popBackStack(R.id.welcomeScreenFragment, false)
            } else {
                emailVerificationViewModel.sendVerificationEmail()
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
                        findNavController().navigate(R.id.action_emailVerificationFragment_to_welcomeScreenFragment)
                    }
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

        emailVerificationViewModel.getShowProgressBarLiveData().observe(this, Observer {
            if(it) {
                progressBarHolder.visibility = View.VISIBLE
                progressBarHolder.animate().setDuration(200).alpha(1.0f).start()
            } else {
                progressBarHolder.animate().setDuration(200).alpha(0.0f).withEndAction {
                    progressBarHolder.visibility = View.GONE
                }.start()
            }
        })
    }

    private fun showLoading(show: Boolean) {
        emailVerificationViewModel.showProgressBar(show)
    }
}
