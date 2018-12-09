package com.appapply.igflexin.ui.app.instagramaccounts

import android.os.Bundle
import android.util.Log
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.appcompat.app.AlertDialog

import com.appapply.igflexin.R
import com.appapply.igflexin.common.InstagramStatusCode
import com.appapply.igflexin.common.StatusCode
import com.appapply.igflexin.events.EventObserver
import com.appapply.igflexin.ui.app.AppViewModel
import kotlinx.android.synthetic.main.dialog_add_ig_account.view.*
import kotlinx.android.synthetic.main.instagram_accounts_fragment.*
import org.koin.androidx.viewmodel.ext.android.sharedViewModel
import org.koin.androidx.viewmodel.ext.android.viewModel

class InstagramAccountsFragment : Fragment() {

    private val viewModel: InstagramAccountsViewModel by viewModel()
    private val appViewModel: AppViewModel by sharedViewModel()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.instagram_accounts_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        Log.d("IGFlexin_instagram", "HEH")

        fab.setOnClickListener {
            addInstagramAccount()
        }

        viewModel.addInstagramAccountStatusLiveData.observe(this, EventObserver {
            when (it) {
                StatusCode.PENDING -> appViewModel.showProgressBar(true)
                StatusCode.ERROR -> showErrorDialog("Error occurred while adding instagram account.")
                StatusCode.NETWORK_ERROR -> showErrorDialog("Error occurred while adding instagram account. Check your internet connection.")
                InstagramStatusCode.BAD_PASSWORD -> showErrorDialog("Bad username and password combination.")
                InstagramStatusCode.ACCOUNT_DOES_NOT_MEET_REQUIREMENTS -> showErrorDialog("Your account does not meet the specified requirements. Consider upgrading your subscription.")
            }
        })
    }

    private fun addInstagramAccount() {
        val dialogBuilder = AlertDialog.Builder(requireContext())
        val dialogView = layoutInflater.inflate(R.layout.dialog_add_ig_account, null)

        dialogBuilder.setTitle("Add an IG account")
        dialogBuilder.setView(dialogView)
        dialogBuilder.setPositiveButton(getString(R.string.add), null)
        dialogBuilder.setNegativeButton(R.string.cancel) { dialogInterface, _ ->
            dialogInterface.cancel()
        }

        val dialog = dialogBuilder.create()

        dialog.setOnShowListener {
            (dialog as AlertDialog).getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener {
                if(dialogView.nickEditText.text.isNullOrBlank() || dialogView.passwordEditText.text.isNullOrBlank()) return@setOnClickListener

                appViewModel.subscriptionLiveData.value?.data?.subscriptionID?.let { it1 ->
                    viewModel.addInstagramAccount(dialogView.nickEditText.text.toString(), dialogView.passwordEditText.text.toString(),
                        it1
                    )
                }

                dialog.dismiss()
            }
        }

        dialog.show()
    }

    private fun showErrorDialog(message: String) {
        appViewModel.showProgressBar(false)
        val dialogBuilder = AlertDialog.Builder(requireContext())

        dialogBuilder.setTitle(getString(R.string.error))
        dialogBuilder.setMessage(message)
        dialogBuilder.setPositiveButton(getString(R.string.ok)) { dialogInterface, _ ->
            dialogInterface.cancel()
        }

        dialogBuilder.setCancelable(false)

        val dialog = dialogBuilder.create()
        dialog.show()
    }
}
