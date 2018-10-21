package com.appapply.igflexin.ui.subscriptionselectiondetail

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.navigation.NavController
import androidx.recyclerview.widget.RecyclerView
import com.appapply.igflexin.R
import com.appapply.igflexin.pojo.Subscription
import kotlinx.android.synthetic.main.item_subscription.view.*

class SubscriptionSelectionDetailAdapter(private val navController: NavController, private val action: (id: String) -> Unit) : RecyclerView.Adapter<SubscriptionSelectionDetailAdapter.SubscriptionSelectionDetailViewHolder>() {

    private var list: List<Subscription> = ArrayList()

    class SubscriptionSelectionDetailViewHolder(val subscriptionView: View) : RecyclerView.ViewHolder(subscriptionView)

    fun setList(list: List<Subscription>) {
        this.list = list
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): SubscriptionSelectionDetailViewHolder {

        val subscriptionView = LayoutInflater.from(parent.context).inflate(R.layout.item_subscription, parent, false)
        return SubscriptionSelectionDetailViewHolder(subscriptionView)
    }

    override fun getItemCount(): Int {
        return list.size
    }

    override fun onBindViewHolder(holder: SubscriptionSelectionDetailViewHolder, position: Int) {

        holder.subscriptionView.titleTextView.text = list[position].title
        holder.subscriptionView.descriptionTextView.text = list[position].description


        holder.subscriptionView.selectButton.setOnClickListener {
            action(list[position].id)
        }
    }
}