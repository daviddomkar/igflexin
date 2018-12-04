package com.appapply.igflexin.ui.subscription.bundle

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.appapply.igflexin.R
import com.appapply.igflexin.model.SubscriptionBundle
import kotlinx.android.synthetic.main.model_subscription_bundle.view.*

class BundleAdapter(private val action: (id: String) -> Unit) : RecyclerView.Adapter<BundleAdapter.BundleViewHolder>() {

    private var list: List<SubscriptionBundle> = ArrayList()

    fun setList(list: List<SubscriptionBundle>) {
        this.list = list
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
        holder.bundleView.titleTextView.text = list[position].title
        holder.bundleView.descriptionTextView.text = list[position].description
        holder.bundleView.restrictionTextView.text = list[position].restriction
        holder.bundleView.selectButton.text = list[position].price
        holder.bundleView.selectButton.setOnClickListener {
            action(list[position].id)
        }
    }
}