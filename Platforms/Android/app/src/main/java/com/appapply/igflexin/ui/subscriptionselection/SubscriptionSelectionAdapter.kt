package com.appapply.igflexin.ui.subscriptionselection

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.navigation.NavController
import androidx.recyclerview.widget.RecyclerView
import com.appapply.igflexin.R
import com.appapply.igflexin.pojo.Subscription
import kotlinx.android.synthetic.main.item_subscription.view.*

class SubscriptionSelectionAdapter(private val navController: NavController) : RecyclerView.Adapter<SubscriptionSelectionAdapter.SubscriptionSelectionViewHolder>() {

    private var list: List<Subscription> = ArrayList()

    class SubscriptionSelectionViewHolder(val subscriptionView: View) : RecyclerView.ViewHolder(subscriptionView)

    fun setList(list: List<Subscription>) {
        this.list = list
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): SubscriptionSelectionViewHolder {

        val subscriptionView = LayoutInflater.from(parent.context).inflate(R.layout.item_subscription, parent, false)
        return SubscriptionSelectionViewHolder(subscriptionView)
    }

    override fun getItemCount(): Int {
        return list.size
    }

    override fun onBindViewHolder(holder: SubscriptionSelectionViewHolder, position: Int) {
        holder.subscriptionView.titleTextView.text = list[position].title
        holder.subscriptionView.descriptionTextView.text = list[position].description
        holder.subscriptionView.selectButton.setOnClickListener {
            val action = SubscriptionSelectionFragmentDirections.actionSubscriptionSelectionFragmentToSubscriptionSelectionDetailFragment()
            action.setSubscriptionID(list[position].id)
            navController.navigate(action)
        }
    }
}