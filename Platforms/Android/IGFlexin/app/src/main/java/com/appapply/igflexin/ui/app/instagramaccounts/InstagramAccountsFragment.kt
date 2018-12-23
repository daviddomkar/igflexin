package com.appapply.igflexin.ui.app.instagramaccounts

import android.annotation.SuppressLint
import android.os.Bundle
import android.util.Log
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.appcompat.app.AlertDialog
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.LinearLayoutManager
import com.appapply.igflexin.IGFlexinService

import com.appapply.igflexin.R
import com.appapply.igflexin.common.InstagramStatusCode
import com.appapply.igflexin.common.StatusCode
import com.appapply.igflexin.events.EventObserver
import com.appapply.igflexin.ui.app.AppViewModel
import com.google.firebase.auth.FirebaseAuth
import kotlinx.android.synthetic.main.dialog_add_ig_account.view.*
import kotlinx.android.synthetic.main.dialog_edit_ig_account.view.*
import kotlinx.android.synthetic.main.instagram_accounts_fragment.*
import org.koin.androidx.viewmodel.ext.android.sharedViewModel
import org.koin.androidx.viewmodel.ext.android.viewModel
import java.lang.Exception

class InstagramAccountsFragment : Fragment() {

    private val viewModel: InstagramAccountsViewModel by viewModel()
    private val appViewModel: AppViewModel by sharedViewModel()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.instagram_accounts_fragment, container, false)
    }

    @SuppressLint("RestrictedApi")
    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        fab.setOnClickListener {
            addInstagramAccount()
        }

        val viewManager = LinearLayoutManager(requireContext())
        val viewAdapter = InstagramAccountsAdapter(requireContext(), this, FirebaseAuth.getInstance().currentUser!!.uid, {
            progressBar.visibility = View.GONE
            if (it.itemCount > 0) {
                viewModel.showErrorLayout(false)
                IGFlexinService.start(requireContext())
            } else {
                errorTextView.text = getString(R.string.no_accounts_found)
                retryButton.text = getString(R.string.add_your_first_account)
                retryButton.setOnClickListener { _ ->
                    addInstagramAccount()
                }
                viewModel.showErrorLayout(true)
            }
        }, { it, e ->
            // TODO do something with error
            errorTextView.text = getString(R.string.error_occured_while_loading_your_accounts)
            retryButton.text = getString(R.string.retry)
            retryButton.setOnClickListener { _ ->
                progressBar.visibility = View.VISIBLE
                it.stopListening()
                viewModel.showErrorLayout(false)
                it.startListening()
            }
            viewModel.showErrorLayout(true)
        }, { username, encryptedPassword, onSucces, onError ->
            viewModel.getInstagramAccountInfo(username, encryptedPassword, onSucces, onError)
        }, {
            editInstagramAccount(it)
        }, {
            showDeleteDialog(it)
        })

        instagramAccountsRecyclerView.isNestedScrollingEnabled = false
        instagramAccountsRecyclerView.apply {
            layoutManager = viewManager
            adapter = viewAdapter
        }

        viewModel.showErrorLayoutLiveData.observe(this, Observer {
            if (it) {
                errorLayout.visibility = View.VISIBLE
                errorLayout.animate().setDuration(200).alpha(1.0f).start()
                fab.animate().setDuration(200).alpha(0.0f).withEndAction {
                    try {
                        fab.visibility = View.GONE
                    } catch (e: Exception) { }
                }.start()
            } else {
                fab.visibility = View.VISIBLE
                fab.animate().setDuration(200).alpha(1.0f).start()
                errorLayout.animate().setDuration(200).alpha(0.0f).withEndAction {
                    try {
                        errorLayout.visibility = View.GONE
                    } catch (e: Exception) { }
                }.start()
            }
        })

        viewModel.connectionLiveData.observe(this, Observer {
            if (it) {
                viewAdapter.stopListening()
                viewAdapter.startListening()
            }
        })

        viewModel.addInstagramAccountStatusLiveData.observe(this, EventObserver {
            when (it) {
                StatusCode.PENDING -> appViewModel.showProgressBar(true)
                StatusCode.ERROR -> showErrorDialog("Error occurred while adding instagram account.")
                StatusCode.NETWORK_ERROR -> showErrorDialog("Error occurred while adding instagram account. Check your internet connection.")
                InstagramStatusCode.BAD_PASSWORD -> showErrorDialog("Bad username and password combination.")
                InstagramStatusCode.ACCOUNT_DOES_NOT_MEET_REQUIREMENTS -> showErrorDialog("Your account does not meet the specified requirements. Consider upgrading your subscription.")
                InstagramStatusCode.ACCOUNT_ALREADY_ADDED -> showErrorDialog("This account is already added to IGFlexin.")
                InstagramStatusCode.RESTRICTED_BY_SUBSCRIPTION_PLAN -> showErrorDialog("You have reached maximum account limit for your subscription plan. Consider upgrading your subscription.")
                else -> {
                    appViewModel.showProgressBar(false)
                }
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

    private fun editInstagramAccount(username: String) {
        val dialogBuilder = AlertDialog.Builder(requireContext())
        val dialogView = layoutInflater.inflate(R.layout.dialog_edit_ig_account, null)

        dialogBuilder.setTitle("Edit $username account")
        dialogBuilder.setView(dialogView)
        dialogBuilder.setPositiveButton(getString(R.string.edit), null)
        dialogBuilder.setNegativeButton(R.string.cancel) { dialogInterface, _ ->
            dialogInterface.cancel()
        }

        val dialog = dialogBuilder.create()

        dialog.setOnShowListener {
            (dialog as AlertDialog).getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener {
                if(dialogView.newPasswordEditText.text.isNullOrBlank()) return@setOnClickListener

                viewModel.editInstagramAccount(username, dialogView.newPasswordEditText.text.toString())

                dialog.dismiss()
            }
        }

        dialog.show()
    }

    private fun showDeleteDialog(username: String) {
        appViewModel.showProgressBar(false)
        val dialogBuilder = AlertDialog.Builder(requireContext())

        dialogBuilder.setTitle("Are you sure?")
        dialogBuilder.setMessage("This operation will delete your IG account and all its statistics.")
        dialogBuilder.setNegativeButton(getString(R.string.cancel)) { dialogInterface, _ ->
            dialogInterface.cancel()
        }
        dialogBuilder.setPositiveButton(getString(R.string.ok)) { _, _ ->
            viewModel.deleteInstagramAccount(username)
        }

        dialogBuilder.setCancelable(false)

        val dialog = dialogBuilder.create()
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
