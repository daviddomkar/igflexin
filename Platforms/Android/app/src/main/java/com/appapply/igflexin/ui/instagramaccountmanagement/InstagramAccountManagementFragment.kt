package com.appapply.igflexin.ui.instagramaccountmanagement

import android.content.Context
import androidx.lifecycle.ViewModelProviders
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.appcompat.app.AlertDialog
import androidx.navigation.fragment.findNavController

import com.appapply.igflexin.R
import kotlinx.android.synthetic.main.instagram_account_management_fragment.*

class InstagramAccountManagementFragment : Fragment() {

    private lateinit var viewModel: InstagramAccountManagementViewModel

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.instagram_account_management_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        viewModel = ViewModelProviders.of(this).get(InstagramAccountManagementViewModel::class.java)
        // TODO: Use the ViewModel
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        floatingActionButton.setOnClickListener {
            val dialogBuilder = AlertDialog.Builder(requireContext())

            val dialogView = layoutInflater.inflate(R.layout.dialog_add_ig_account, null)

            dialogBuilder.setTitle(getString(R.string.add_an_ig_account))
            dialogBuilder.setView(dialogView)
            dialogBuilder.setPositiveButton("Add", null)
            dialogBuilder.setNegativeButton("Cancel", null)

            val dialog = dialogBuilder.create()

            dialog.show()

            /*
            val dialogView = layoutInflater.inflate(R.layout.dialog_email_contact, null)

            dialogBuilder.setTitle(R.string.add_email_contact)
            dialogBuilder.setView(dialogView)
            dialogBuilder.setPositiveButton(R.string.add, null)
            dialogBuilder.setNegativeButton(R.string.cancel) { dialogInterface, _ ->
                dialogInterface.cancel()
            }

            val dialog = dialogBuilder.create()

            dialog.setOnShowListener {
                (dialog as AlertDialog).getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener {
                    if(dialogView.nameEditText.text.isNullOrBlank() || dialogView.emailEditText.text.isNullOrBlank() || !Patterns.EMAIL_ADDRESS.matcher(dialogView.emailEditText.text).matches()) return@setOnClickListener

                    contactsList.add(Contact(dialogView.nameEditText.text.toString(), dialogView.emailEditText.text.toString()))

                    sharedPreferencesEditor = sharedPreferences.edit()
                    sharedPreferencesEditor.putString("contacts", gson.toJson(contactsList))
                    sharedPreferencesEditor.apply()

                    noContactsFoundTextView.visibility = View.GONE

                    dialog.dismiss()
                }
            }

            dialog.show()*/
        }
    }
}
