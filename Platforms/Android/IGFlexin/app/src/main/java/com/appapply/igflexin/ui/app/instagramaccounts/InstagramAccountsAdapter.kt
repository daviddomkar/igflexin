package com.appapply.igflexin.ui.app.instagramaccounts

import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.LifecycleOwner
import androidx.recyclerview.widget.RecyclerView
import com.appapply.igflexin.R
import com.appapply.igflexin.model.InstagramAccount
import com.firebase.ui.firestore.FirestoreRecyclerAdapter
import com.firebase.ui.firestore.FirestoreRecyclerOptions
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.FirebaseFirestoreException
import kotlinx.android.synthetic.main.model_instagram_account.view.*

class InstagramAccountsAdapter(private val lifecycleOwner: LifecycleOwner, private val userID: String, private val actionDataChanged: () -> Unit, private val actionError: (e: FirebaseFirestoreException) -> Unit) : FirestoreRecyclerAdapter<InstagramAccount, InstagramAccountsAdapter.InstagramAccountHolder>(FirestoreRecyclerOptions.Builder<InstagramAccount>().setLifecycleOwner(lifecycleOwner).setQuery(FirebaseFirestore.getInstance().collection("accounts").whereEqualTo("userID", userID), InstagramAccount::class.java).build()) {

    class InstagramAccountHolder(val instagramAccountView: View) : RecyclerView.ViewHolder(instagramAccountView)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): InstagramAccountHolder {
        return InstagramAccountHolder(LayoutInflater.from(parent.context).inflate(R.layout.model_instagram_account, parent, false))
    }

    override fun onBindViewHolder(holder: InstagramAccountHolder, position: Int, account: InstagramAccount) {
        holder.instagramAccountView.usernameTextView.text = account.username
    }

    override fun onDataChanged() {
        actionDataChanged()
    }

    override fun onError(e: FirebaseFirestoreException) {
        Log.d("IGFlexin_instagram", "Exception: " + e.message)
        actionError(e)
    }
}