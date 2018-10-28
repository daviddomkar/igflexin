package com.appapply.igflexin.ui.signin

import android.content.Context
import android.os.Build
import android.os.Bundle
import android.view.*
import android.view.inputmethod.InputMethodManager
import androidx.fragment.app.Fragment
import androidx.lifecycle.Observer
import androidx.navigation.fragment.findNavController
import com.appapply.igflexin.MainActivityViewModel
import com.appapply.igflexin.R
import com.appapply.igflexin.codes.AuthStatusCode
import com.appapply.igflexin.codes.StatusCode
import com.appapply.igflexin.events.EventObserver
import kotlinx.android.synthetic.main.sign_in_fragment.*
import org.koin.androidx.viewmodel.ext.android.sharedViewModel
import org.koin.androidx.viewmodel.ext.android.viewModel
import java.util.regex.Pattern

class SignInFragment : Fragment() {

    private val emailPattern = "^[a-zA-Z0-9#_~!$&'()*+,;=:.\"(),:;<>@\\[\\]\\\\]+@[a-zA-Z0-9-]+(\\.[a-zA-Z0-9-]+)*$"
    private val emailPatternCompiled = Pattern.compile(emailPattern)

    private val mainActivityViewModel: MainActivityViewModel by sharedViewModel()
    private val signInViewModel: SignInViewModel by viewModel()

    private lateinit var inputManager: InputMethodManager

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        inputManager = requireActivity().getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        return inflater.inflate(R.layout.sign_in_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        //TODO Create pending state
        signInViewModel.getAuthStatusLiveData().observe(this, EventObserver {
            handleAuthStatus(it)
        })
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        backImageButton.setOnClickListener {
            findNavController().popBackStack(R.id.welcomeScreenFragment, false)
        }

        signInButton.setOnClickListener {
            val email = emailInputEditText.text.toString()
            val password = passwordInputEditText.text.toString()

            if (email.isBlank()) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    if (emailInputEditText.autofillValue?.textValue.isNullOrBlank()) {
                        emailInputEditText.error = getString(R.string.error_field_required)
                    }
                } else {
                    emailInputEditText.error = getString(R.string.error_field_required)
                }
            } else if (!validateEmail(email)) {
                emailInputEditText.error = getString(R.string.error_email)
            }

            if (password.isBlank()) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    if (passwordInputEditText.autofillValue?.textValue.isNullOrBlank()) {
                        passwordInputEditText.error = getString(R.string.error_field_required)
                    }
                } else {
                    passwordInputEditText.error = getString(R.string.error_field_required)
                }
            }

            if(email.isNotBlank() && password.isNotBlank()) {
                hideKeyboard(emailInputEditText)
                showLoading(true)
                signInViewModel.signIn(email, password)
            }
        }
    }

    private fun validateEmail(email: String): Boolean {
        val matcher = emailPatternCompiled.matcher(email)
        return matcher.matches()
    }

    private fun showLoading(show: Boolean) {
        mainActivityViewModel.disableBackNavigation(show)
        mainActivityViewModel.showProgressBar(show, false)
    }

    private fun hideKeyboard(view: View) {
        inputManager.hideSoftInputFromWindow(view.windowToken, InputMethodManager.HIDE_NOT_ALWAYS)
    }

    private fun handleAuthStatus(authStatusCode: StatusCode) {
        if(authStatusCode != StatusCode.SUCCESS) {
            showLoading(false)
        }

        when(authStatusCode) {
            StatusCode.SUCCESS -> {
                mainActivityViewModel.disableBackNavigation(false)
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
}
