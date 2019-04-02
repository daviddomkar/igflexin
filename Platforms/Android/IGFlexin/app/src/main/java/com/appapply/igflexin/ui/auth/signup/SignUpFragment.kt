package com.appapply.igflexin.ui.auth.signup

import android.content.Context
import android.os.Build
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.InputMethodManager
import androidx.navigation.fragment.findNavController

import com.appapply.igflexin.R
import com.appapply.igflexin.ui.auth.AuthViewModel
import kotlinx.android.synthetic.main.sign_up_fragment.*
import org.koin.androidx.viewmodel.ext.android.sharedViewModel
import org.koin.androidx.viewmodel.ext.android.viewModel
import java.util.regex.Pattern

class SignUpFragment : Fragment() {

    private val emailPattern = "^[a-zA-Z0-9#_~!$&'()*+,;=:.\"(),:;<>@\\[\\]\\\\]+@[a-zA-Z0-9-]+(\\.[a-zA-Z0-9-]+)*$"
    private val passwordPattern = "^(?=.*[\\p{Ll}])(?=.*[\\p{Lu}])(?=.*\\d)[\\p{Ll}\\p{Lu}\\d\$@\$!%*?&]{8,}"

    private val emailPatternCompiled = Pattern.compile(emailPattern)
    private val passwordPatternCompiled = Pattern.compile(passwordPattern)

    private val viewModel: SignUpViewModel by viewModel()
    private val authViewModel: AuthViewModel by sharedViewModel()

    private lateinit var inputManager: InputMethodManager

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        inputManager = requireActivity().getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        return inflater.inflate(R.layout.sign_up_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        backImageButton.setOnClickListener {
            hideKeyboard(nameInputEditText)
            findNavController().popBackStack()
        }

        signUpButton.setOnClickListener {
            val name = nameInputEditText.text.toString()
            val email = emailInputEditText.text.toString()
            val password = passwordInputEditText.text.toString()
            val passwordAgain = passwordAgainInputEditText.text.toString()

            if (name.isBlank()) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    if(nameInputEditText.autofillValue?.textValue.isNullOrBlank()) {
                        nameInputEditText.error = getString(R.string.error_field_required)
                    }
                } else {
                    nameInputEditText.error = getString(R.string.error_field_required)
                }
            } else if (!validateName(name)) {
                nameInputEditText.error = getString(R.string.error_name)
            }

            if (email.isBlank()) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    if(emailInputEditText.autofillValue?.textValue.isNullOrBlank()) {
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
                    if(passwordInputEditText.autofillValue?.textValue.isNullOrBlank()) {
                        passwordInputEditText.error = getString(R.string.error_field_required)
                    }
                } else {
                    passwordInputEditText.error = getString(R.string.error_field_required)
                }
            } else if (!validatePassword(password)) {
                passwordInputEditText.error = getString(R.string.error_password)
            }

            if (passwordAgain.isBlank()) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    if(passwordAgainInputEditText.autofillValue?.textValue.isNullOrBlank()) {
                        passwordAgainInputEditText.error = getString(R.string.error_field_required)
                    }
                } else {
                    passwordAgainInputEditText.error = getString(R.string.error_field_required)
                }
            } else if (!validatePasswordAgain(password, passwordAgain)) {
                passwordAgainInputEditText.error = getString(R.string.error_password_again)
            }

            if (validateName(name) && validateEmail(email) && validatePassword(password) && validatePasswordAgain(password, passwordAgain)) {
                hideKeyboard(nameInputEditText)
                authViewModel.showProgressBar(true)
                viewModel.signUp(name, email, password)
            }
        }

        // TODO Make drawable white to enable this
        //passwordInputLayout.isPasswordVisibilityToggleEnabled = true
        //passwordAgainInputLayout.isPasswordVisibilityToggleEnabled = true
    }

    private fun validateName(name: String): Boolean {
        return name.length > 2
    }

    private fun validateEmail(email: String): Boolean {
        val matcher = emailPatternCompiled.matcher(email)
        return matcher.matches()
    }

    private fun validatePassword(password: String): Boolean {
        val matcher = passwordPatternCompiled.matcher(password)
        return matcher.matches()
    }

    private fun validatePasswordAgain(password: String, passwordAgain: String): Boolean {
        return password == passwordAgain
    }

    private fun hideKeyboard(view: View) {
        inputManager.hideSoftInputFromWindow(view.windowToken, InputMethodManager.HIDE_NOT_ALWAYS)
    }
}
