package com.appapply.igflexin.ui.subscription.bundle

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.appapply.igflexin.R
import com.appapply.igflexin.model.SubscriptionBundle
import kotlinx.android.synthetic.main.model_subscription_bundle.view.*

class BundleAdapter(private val context: Context, private val action: (id: String) -> Unit) : RecyclerView.Adapter<BundleAdapter.BundleViewHolder>() {

    private var list: List<SubscriptionBundle> = ArrayList()

    private var id: String = ""

    fun setList(list: List<SubscriptionBundle>) {
        this.list = list
        notifyDataSetChanged()
    }

    fun setID(id: String) {
        this.id = id
        notifyDataSetChanged()
    }

    class BundleViewHolder(val bundleView: View) : RecyclerView.ViewHolder(bundleView)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BundleViewHolder {
        return BundleViewHolder(LayoutInflater.from(parent.context).inflate(R.layout.model_subscription_bundle, parent, false))
    }

    override fun getItemCount(): Int {
        return list.size
    }

    override fun onBindViewHolder(holder: BundleViewHolder, position: Int) {
        holder.bundleView.usernameTextView.text = list[position].title
        holder.bundleView.descriptionTextView.text = list[position].description
        holder.bundleView.restrictionTextView.text = list[position].restriction

        if (list[position].id == this.id) {
            holder.bundleView.selectButton.text = context.getString(R.string.restore)
            holder.bundleView.selectButton.setOnClickListener {
                val url = "https://play.google.com/store/account/subscriptions?sku=" + this.id + "&package=com.appapply.igflexin"
                val i = Intent(Intent.ACTION_VIEW)
                i.data = Uri.parse(url)
                context.startActivity(i)
            }
        } else {
            holder.bundleView.selectButton.text = list[position].price
            holder.bundleView.selectButton.setOnClickListener {
                action(list[position].id)
            }
        }
    }
}