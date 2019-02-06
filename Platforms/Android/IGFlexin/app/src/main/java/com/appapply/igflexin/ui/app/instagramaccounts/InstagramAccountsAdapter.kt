package com.appapply.igflexin.ui.app.instagramaccounts

import android.content.Context
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.LifecycleOwner
import androidx.recyclerview.widget.RecyclerView
import com.appapply.igflexin.model.InstagramAccount
import com.firebase.ui.firestore.FirestoreRecyclerAdapter
import com.firebase.ui.firestore.FirestoreRecyclerOptions
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.FirebaseFirestoreException
import kotlinx.android.synthetic.main.model_instagram_account.view.*
import com.appapply.igflexin.GlideApp
import com.appapply.igflexin.R


class InstagramAccountsAdapter(private val context: Context, private val lifecycleOwner: LifecycleOwner, private val userID: String, private val actionDataChanged: (viewAdapter: InstagramAccountsAdapter) -> Unit, private val actionError: (viewAdapter: InstagramAccountsAdapter, e: FirebaseFirestoreException) -> Unit, private val actionEdit: (id: Long, username: String) -> Unit, private val actionDelete: (id: Long) -> Unit, private val actionPause: (id: Long) -> Unit, private val actionStart: (id: Long) -> Unit) : FirestoreRecyclerAdapter<InstagramAccount, InstagramAccountsAdapter.InstagramAccountHolder>(FirestoreRecyclerOptions.Builder<InstagramAccount>().setLifecycleOwner(lifecycleOwner).setQuery(FirebaseFirestore.getInstance().collection("accounts").whereEqualTo("userID", userID), InstagramAccount::class.java).build()) {

    class InstagramAccountHolder(val instagramAccountView: View) : RecyclerView.ViewHolder(instagramAccountView)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): InstagramAccountHolder {
        return InstagramAccountHolder(LayoutInflater.from(parent.context).inflate(R.layout.model_instagram_account, parent, false))
    }

    override fun onBindViewHolder(holder: InstagramAccountHolder, position: Int, account: InstagramAccount) {
        holder.instagramAccountView.usernameTextView.text = account.username
        holder.instagramAccountView.fullNameTextView.text = account.fullName

        GlideApp.with(context).load(account.photoURL).into(holder.instagramAccountView.imageView)

        when (account.status) {
            "running" -> {
                holder.instagramAccountView.pauseButton.visibility = View.VISIBLE
                holder.instagramAccountView.pauseButton.text = "PAUSE"
                holder.instagramAccountView.pauseButton.setOnClickListener {
                    actionPause(account.id)
                }
            }
            "paused" -> {
                holder.instagramAccountView.pauseButton.visibility = View.VISIBLE
                holder.instagramAccountView.pauseButton.text = "RESUME"
                holder.instagramAccountView.pauseButton.setOnClickListener {
                    actionStart(account.id)
                }
            }
            else -> {
                holder.instagramAccountView.pauseButton.visibility = View.GONE
            }
        }

        holder.instagramAccountView.statusTextView.text = when (account.status) {
            "paused" -> context.getString(R.string.status) + " " + "Paused"
            "bad_password" -> context.getString(R.string.status) + " " + "Bad password"
            "requirements_not_met" -> context.getString(R.string.status) + " " + "Subscription upgrade required"
            "low_subscription" -> context.getString(R.string.status) + " " + "Subscription upgrade required"
            "running" -> context.getString(R.string.status) + " " + "Running"
            else -> context.getString(R.string.status) + " " + "Unknown"
        }

        holder.instagramAccountView.editButton.setOnClickListener {
            actionEdit(account.id, account.username)
        }

        holder.instagramAccountView.deleteButton.setOnClickListener {
            actionDelete(account.id)
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