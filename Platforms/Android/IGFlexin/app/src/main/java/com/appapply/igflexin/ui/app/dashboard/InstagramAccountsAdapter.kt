package com.appapply.igflexin.ui.app.dashboard

import android.app.Activity
import android.graphics.Color
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import com.appapply.igflexin.GlideApp
import com.appapply.igflexin.model.InstagramAccount
import kotlinx.android.synthetic.main.instagram_account_spinner_row.view.*

class InstagramAccountsAdapter(private val activity: Activity, private val resource: Int, private val accounts: List<InstagramAccount>) : ArrayAdapter<InstagramAccount>(activity, resource, accounts) {

    val instagramAccounts get() = accounts

    override fun getDropDownView(position: Int, convertView: View?, parent: ViewGroup): View {
        return getInstagramAccountView(position, parent)
    }

    override fun getView(position: Int, convertView: View?, parent: ViewGroup): View {
        val view =  getInstagramAccountView(position, parent)
        view.instagramTextView.setTextColor(Color.WHITE)
        return view
    }

    private fun getInstagramAccountView(position: Int, parent: ViewGroup): View {
        val view = activity.layoutInflater.inflate(resource, parent, false)
        val account = accounts[position]

        view.instagramTextView.text = account.username
        GlideApp.with(context).load(account.photoURL).into(view.imageView)

        return view
    }
}