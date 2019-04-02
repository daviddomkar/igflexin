package com.appapply.igflexin.livedata

import android.util.Log
import androidx.lifecycle.LiveData
import com.appapply.igflexin.common.InstagramStatusCode
import com.appapply.igflexin.common.Resource
import com.appapply.igflexin.common.StatusCode
import com.appapply.igflexin.model.InstagramStatistics
import com.google.firebase.firestore.*
import com.google.firebase.firestore.EventListener
import org.koin.standalone.KoinComponent
import org.koin.standalone.inject
import kotlin.collections.ArrayList

class InstagramRecordsLiveData: LiveData<Resource<InstagramStatistics>>(), KoinComponent {

    private val firestore: FirebaseFirestore by inject()

    private var listenerRegistration: ListenerRegistration? = null

    private var id: Long = -1

    fun setStatsID(id: Long) {
        Log.d("IGFlexin_records", "Stats will load for id: $id")

        if (this.id != id) {
            this.id = id
            updateRecordsIDAndPeriod()
        }
    }

    private fun updateRecordsIDAndPeriod() {
        if (this.id == -1L)
            return

        listenerRegistration?.remove()
        listenerRegistration = firestore.collection("statistics").document(id.toString()).addSnapshotListener(MetadataChanges.EXCLUDE, InstagramRecordsListener())
    }

    override fun onActive() {
        super.onActive()

        if (this.id == -1L)
            return

        listenerRegistration?.remove()
        listenerRegistration = firestore.collection("statistics").document(id.toString()).addSnapshotListener(MetadataChanges.EXCLUDE, InstagramRecordsListener())
    }

    override fun onInactive() {
        super.onInactive()
        listenerRegistration?.remove()
    }

    inner class InstagramRecordsListener: EventListener<DocumentSnapshot> {

        override fun onEvent(snapshot: DocumentSnapshot?, exception: FirebaseFirestoreException?) {
            var resource = Resource<InstagramStatistics>(StatusCode.ERROR, null)

            if (snapshot != null) {
                if (snapshot.exists()) {



                    val statistics = InstagramStatistics(snapshot.getTimestamp("lastAction", DocumentSnapshot.ServerTimestampBehavior.ESTIMATE)!!.toDate(), snapshot.get("hours_of_day")!! as ArrayList<Number?>, snapshot.get("days_of_week")!! as ArrayList<Number?>, snapshot.get("days_of_month")!! as ArrayList<Number?>)
                    resource = Resource(StatusCode.SUCCESS, statistics)
                    Log.d("IGFlexin_records", "Stats loaded for id: ${snapshot.id}")
                } else {
                    resource = Resource(InstagramStatusCode.DATA_EMPTY, null)
                }
            }
            value = resource
        }
    }
}