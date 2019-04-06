package com.appapply.igflexin.ui.auth.login

import android.content.Context
import android.os.Build
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
import android.view.inputmethod.InputMethodManager
import androidx.appcompat.app.AlertDialog
import androidx.core.content.res.ResourcesCompat
import androidx.navigation.fragment.findNavController

import com.appapply.igflexin.R
import com.appapply.igflexin.common.StatusCode
import com.appapply.igflexin.events.EventObserver
import com.appapply.igflexin.ui.auth.AuthViewModel
import kotlinx.android.synthetic.main.dialog_reset_password.*
import kotlinx.android.synthetic.main.dialog_reset_password.view.*
import kotlinx.android.synthetic.main.log_in_fragment.*
import org.koin.androidx.viewmodel.ext.android.sharedViewModel
import org.koin.androidx.viewmodel.ext.android.viewModel
import java.util.regex.Pattern

class LogInFragment : Fragment() {
    private val emailPattern = "^[a-zA-Z0-9#_~!$&'()*+,;=:.\"(),:;<>@\\[\\]\\\\]+@[a-zA-Z0-9-]+(\\.[a-zA-Z0-9-]+)*$"
    private val emailPatternCompiled = Pattern.compile(emailPattern)

    private val viewModel: LogInViewModel by viewModel()
    private val authViewModel: AuthViewModel by sharedViewModel()

    private lateinit var inputManager: InputMethodManager

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        inputManager = requireActivity().getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        return inflater.inflate(R.layout.log_in_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        backImageButton.setOnClickListener {
            hideKeyboard(emailInputEditText)
            findNavController().popBackStack()
        }

        logInButton.setOnClickListener {
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
                authViewModel.showProgressBar(true)
                viewModel.signIn(email, password)
            }
        }

        val forgotPasswordSpannableString = SpannableString("Forgot password?")
        val forgotPasswordClickableSpan = object : ClickableSpan() {
            override fun onClick(textView: View) {
                val dialogBuilder = AlertDialog.Builder(requireContext())
                val dialogView = layoutInflater.inflate(R.layout.dialog_reset_password, null)

                dialogBuilder.setTitle("Password reset")
                dialogBuilder.setView(dialogView)
                dialogBuilder.setPositiveButton("SEND", null)
                dialogBuilder.setNegativeButton(R.string.cancel) { dialogInterface, _ ->
                    dialogInterface.cancel()
                }

                dialogBuilder.setCancelable(false)

                val dialog = dialogBuilder.create()

                dialog.setOnShowListener {
                    (dialog as AlertDialog).getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener {
                        if(dialogView.emailEditText.text.isNullOrBlank() || !validateEmail(dialogView.emailEditText.text.toString())) return@setOnClickListener

                        viewModel.resetPassword(dialog.emailEditText.text.toString())

                        dialog.dismiss()
                    }
                }

                dialog.show()
            }

            override fun updateDrawState(textPaint: TextPaint) {
                super.updateDrawState(textPaint)
                textPaint.isUnderlineText = true
            }
        }
        forgotPasswordSpannableString.setSpan(forgotPasswordClickableSpan, 0, 16, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)

        forgotPasswordTextView.text = forgotPasswordSpannableString
        forgotPasswordTextView.movementMethod = LinkMovementMethod.getInstance()
        forgotPasswordTextView.highlightColor = ResourcesCompat.getColor(resources, R.color.colorAccent, null)

        viewModel.passwordResetStatusLiveData.observe(this, EventObserver {
            when (it) {
                StatusCode.PENDING -> {
                    authViewModel.showProgressBar(true)
                }
                StatusCode.SUCCESS -> {
                    authViewModel.showProgressBar(false)
                    authViewModel.snack("Password reset email was sent!")
                }
                StatusCode.NETWORK_ERROR -> {
                    authViewModel.showProgressBar(false)
                    authViewModel.snack("Error occurred while sending an email, no internet connection!")
                }
                StatusCode.ERROR -> {
                    authViewModel.showProgressBar(false)
                    authViewModel.snack("Error occurred while sending an email!")
                }
            }
        })
    }

    private fun validateEmail(email: String): Boolean {
        val matcher = emailPatternCompiled.matcher(email)
        return matcher.matches()
    }

    private fun hideKeyboard(view: View) {
        inputManager.hideSoftInputFromWindow(view.windowToken, InputMethodManager.HIDE_NOT_ALWAYS)
    }
}
