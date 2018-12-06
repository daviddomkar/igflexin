package com.appapply.igflexin.ui.app.subscriptionmanagement.subscriptiontab

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.appapply.igflexin.R
import com.appapply.igflexin.model.SubscriptionBundle
import kotlinx.android.synthetic.main.model_subscription_change.view.*

class SubscriptionTabAdapter(private val action: (id: String) -> Unit) : RecyclerView.Adapter<SubscriptionTabAdapter.SubscriptionTabHolder>() {

    private var list: List<SubscriptionBundle> = ArrayList()

    fun setList(list: List<SubscriptionBundle>) {
        this.list = list
        notifyDataSetChanged()
    }

    class SubscriptionTabHolder(val bundleView: View) : RecyclerView.ViewHolder(bundleView)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): SubscriptionTabHolder {
        return SubscriptionTabHolder(LayoutInflater.from(parent.context).inflate(R.layout.model_subscription_change, parent, false))
    }

    override fun getItemCount(): Int {
        return list.size
    }

    override fun onBindViewHolder(holder: SubscriptionTabHolder, position: Int) {
        holder.bundleView.titleTextView.text = list[position].title
        holder.bundleView.descriptionTextView.text = list[position].description
        holder.bundleView.restrictionTextView.text = list[position].restriction
        holder.bundleView.price.text = list[position].price
        holder.bundleView.selectButton.text = "CHANGE"
        holder.bundleView.selectButton.setOnClickListener {
            action(list[position].id)
        }
    }
}