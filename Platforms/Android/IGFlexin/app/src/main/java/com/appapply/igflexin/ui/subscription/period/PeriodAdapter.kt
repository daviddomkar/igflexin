package com.appapply.igflexin.ui.subscription.period

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.navigation.NavController
import androidx.recyclerview.widget.RecyclerView
import com.appapply.igflexin.R
import com.appapply.igflexin.model.SubscriptionPeriod
import kotlinx.android.synthetic.main.model_subscription_period.view.*

class PeriodAdapter(private val navController: NavController) : RecyclerView.Adapter<PeriodAdapter.PeriodViewHolder>() {

    private var list: List<SubscriptionPeriod> = ArrayList()

    fun setList(list: List<SubscriptionPeriod>) {
        this.list = list
        notifyDataSetChanged()
    }

    class PeriodViewHolder(val periodView: View) : RecyclerView.ViewHolder(periodView)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): PeriodViewHolder {
        return PeriodViewHolder(LayoutInflater.from(parent.context).inflate(R.layout.model_subscription_period, parent, false))
    }

    override fun getItemCount(): Int {
        return list.size
    }

    override fun onBindViewHolder(holder: PeriodViewHolder, position: Int) {
        holder.periodView.usernameTextView.text = list[position].title
        holder.periodView.descriptionTextView.text = list[position].description
        holder.periodView.selectButton.setOnClickListener {
            val action = PeriodFragmentDirections.actionPeriodFragmentToBundleFragment()
            action.setPeriod(list[position].id)
            navController.navigate(action)
        }
    }
}