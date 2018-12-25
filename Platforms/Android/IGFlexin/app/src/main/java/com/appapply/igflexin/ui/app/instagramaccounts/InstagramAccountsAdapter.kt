package com.appapply.igflexin.ui.app.instagramaccounts

import android.content.Context
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.LifecycleOwner
import androidx.recyclerview.widget.RecyclerView
import com.appapply.igflexin.model.InstagramAccount
import com.appapply.igflexin.model.InstagramAccountInfo
import com.firebase.ui.firestore.FirestoreRecyclerAdapter
import com.firebase.ui.firestore.FirestoreRecyclerOptions
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.FirebaseFirestoreException
import kotlinx.android.synthetic.main.model_instagram_account.view.*
import android.graphics.BitmapFactory
import com.appapply.igflexin.IGFlexinService
import com.appapply.igflexin.R
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.net.URL


class InstagramAccountsAdapter(private val context: Context, private val lifecycleOwner: LifecycleOwner, private val userID: String, private val actionDataChanged: (viewAdapter: InstagramAccountsAdapter) -> Unit, private val actionError: (viewAdapter: InstagramAccountsAdapter, e: FirebaseFirestoreException) -> Unit, private val actionAccountInfo: (username: String, encryptedPassword: String, onSucces: (info: InstagramAccountInfo) -> Unit, onError: () -> Unit) -> Unit, private val actionEdit: (username: String) -> Unit, private val actionDelete: (username: String) -> Unit, private val actionPause: (username: String) -> Unit, private val actionStart: (username: String) -> Unit) : FirestoreRecyclerAdapter<InstagramAccount, InstagramAccountsAdapter.InstagramAccountHolder>(FirestoreRecyclerOptions.Builder<InstagramAccount>().setLifecycleOwner(lifecycleOwner).setQuery(FirebaseFirestore.getInstance().collection("accounts").whereEqualTo("userID", userID), InstagramAccount::class.java).build()) {

    class InstagramAccountHolder(val instagramAccountView: View) : RecyclerView.ViewHolder(instagramAccountView)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): InstagramAccountHolder {
        return InstagramAccountHolder(LayoutInflater.from(parent.context).inflate(R.layout.model_instagram_account, parent, false))
    }

    override fun onBindViewHolder(holder: InstagramAccountHolder, position: Int, account: InstagramAccount) {
        holder.instagramAccountView.usernameTextView.text = account.username
        holder.instagramAccountView.fullNameTextView.text = context.getString(R.string.loading_more_info)
        
        actionAccountInfo(account.username, account.encryptedPassword, {
            try {
                holder.instagramAccountView.fullNameTextView.text = it.fullName
                val url = URL(it.profilePictureUrl)
                GlobalScope.launch {
                    val bmp = BitmapFactory.decodeStream(url.openConnection().getInputStream())

                    GlobalScope.launch(Dispatchers.Main) {
                        try {
                            holder.instagramAccountView.imageView.setImageBitmap(bmp)
                        } catch (e: Exception) { }
                    }
                }
            } catch (e: Exception) { }
        }, {
            try {
                holder.instagramAccountView.fullNameTextView.text = context.getString(R.string.error_loading_more_info)
            } catch (e: Exception) { }
        })

        if (account.status != null) {
            when (account.status) {
                "running" -> {
                    holder.instagramAccountView.pauseButton.visibility = View.VISIBLE
                    holder.instagramAccountView.pauseButton.text = "PAUSE"
                    holder.instagramAccountView.pauseButton.setOnClickListener {
                        actionPause(account.username)
                    }
                }
                "paused" -> {
                    holder.instagramAccountView.pauseButton.visibility = View.VISIBLE
                    holder.instagramAccountView.pauseButton.text = "RESUME"
                    holder.instagramAccountView.pauseButton.setOnClickListener {
                        actionStart(account.username)
                    }
                }
            }
        } else {
            holder.instagramAccountView.pauseButton.visibility = View.GONE
        }

        if (account.status != null) {
            holder.instagramAccountView.statusTextView.text = when (account.status) {
                "paused" -> context.getString(R.string.status) + " " + "Paused"
                "bad_password" -> context.getString(R.string.status) + " " + "Bad password"
                "requirements_not_met" -> context.getString(R.string.status) + " " + "Subscription upgrade required"
                "error" -> context.getString(R.string.status) + " " + "Error"
                "running" -> {
                    if (account.serviceID != IGFlexinService.getID()) {
                        context.getString(R.string.status) + " " + "Running on another device"
                    } else {
                        context.getString(R.string.status) + " " + "Running"
                    }
                }
                else -> context.getString(R.string.status) + " " + "Unknown"
            }
        } else {
            holder.instagramAccountView.statusTextView.text = context.getString(R.string.status) + " " + context.getString(R.string.waiting_for_service)
        }

        holder.instagramAccountView.editButton.setOnClickListener {
            actionEdit(account.username)
        }

        holder.instagramAccountView.deleteButton.setOnClickListener {
            actionDelete(account.username)
        }
    }

    override fun onDataChanged() {
        actionDataChanged(this)
    }

    override fun onError(e: FirebaseFirestoreException) {
        Log.d("IGFlexin_instagram", "Exception: " + e.message)
        actionError(this, e)
    }
}