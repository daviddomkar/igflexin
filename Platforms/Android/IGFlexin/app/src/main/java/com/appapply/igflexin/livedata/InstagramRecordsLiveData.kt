package com.appapply.igflexin.livedata

import android.util.Log
import androidx.lifecycle.LiveData
import com.appapply.igflexin.common.InstagramStatusCode
import com.appapply.igflexin.common.Resource
import com.appapply.igflexin.common.StatsPeriod
import com.appapply.igflexin.common.StatusCode
import com.appapply.igflexin.model.InstagramRecord
import com.google.firebase.Timestamp
import com.google.firebase.firestore.*
import com.google.firebase.firestore.EventListener
import org.koin.standalone.KoinComponent
import org.koin.standalone.inject
import java.util.*

typealias Period = Int

class InstagramRecordsLiveData: LiveData<Resource<List<InstagramRecord>>>(), KoinComponent {

    private val firestore: FirebaseFirestore by inject()

    private var listenerRegistration: ListenerRegistration? = null

    private var id: Long = -1
    private var period = -1

    fun setStatsID(id: Long) {
        Log.d("IGFlexin_records", "Stats will load for id: $id")

        if (this.id != id) {
            this.id = id
            updateRecordsIDAndPeriod()
        }
    }

    fun setStatsPeriod(period: Int) {
        Log.d("IGFlexin_records", "Stats will load for period: $period")

        if (this.period != period) {
            this.period = period
            updateRecordsIDAndPeriod()
        }
    }

    private fun updateRecordsIDAndPeriod() {

        if (this.period == -1 || this.id == -1L)
            return

        val cal = Calendar.getInstance()

        when (period) {
            StatsPeriod.DAY -> {
                cal.add(Calendar.HOUR, -24)
            }
            StatsPeriod.WEEK -> {
                cal.add(Calendar.HOUR, -7 * 24)
            }
            StatsPeriod.MONTH -> {
                cal.add(Calendar.HOUR, -7 * 24 * 30)
            }
        }

        val timestamp = Timestamp(cal.time)

        listenerRegistration?.remove()
        listenerRegistration = firestore.collection("records").whereEqualTo("id", id).whereGreaterThan("time", timestamp).addSnapshotListener(MetadataChanges.EXCLUDE, InstagramRecordsListener(this.period))
    }

    override fun onActive() {
        super.onActive()

        if (this.period == -1 || this.id == -1L)
            return

        val cal = Calendar.getInstance()

        when (period) {
            StatsPeriod.DAY -> {
                cal.add(Calendar.HOUR, -24)
            }
            StatsPeriod.WEEK -> {
                cal.add(Calendar.HOUR, -7 * 24)
            }
            StatsPeriod.MONTH -> {
                cal.add(Calendar.HOUR, -7 * 24 * 30)
            }
        }

        val timestamp = Timestamp(cal.time)

        listenerRegistration = firestore.collection("records").whereEqualTo("id", id).whereGreaterThan("time", timestamp).addSnapshotListener(MetadataChanges.EXCLUDE, InstagramRecordsListener(this.period))
    }

    override fun onInactive() {
        super.onInactive()
        listenerRegistration?.remove()
    }

    inner class InstagramRecordsListener(private val check_period: Period): EventListener<QuerySnapshot> {

        override fun onEvent(snapshot: QuerySnapshot?, exception: FirebaseFirestoreException?) {

            var resource = Resource<List<InstagramRecord>>(StatusCode.ERROR, null)

            if (snapshot != null) {
                val records = snapshot.documents.map {
                    val instagramId = it.getLong("id")!!
                    val timestamp = it.getTimestamp("time", DocumentSnapshot.ServerTimestampBehavior.ESTIMATE)!!
                    val followers = it.getLong("followers")!!
                    InstagramRecord(instagramId, timestamp, followers)
                }

                if (!records.isEmpty()) {
                    if (check_period == period && records[0].instagramId == id) {
                        resource = Resource(StatusCode.SUCCESS, records)
                        Log.d("IGFlexin_records", "Stats loaded for period: $period")
                    }
                } else {
                    resource = Resource(InstagramStatusCode.DATA_EMPTY, null)
                }

            }

            value = resource
        }
    }
}