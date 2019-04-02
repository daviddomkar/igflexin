package com.appapply.igflexin.livedata.firebase

import androidx.lifecycle.LiveData
import com.appapply.igflexin.common.DataOrException
import com.appapply.igflexin.events.Event
import com.google.firebase.firestore.Query
import com.google.firebase.firestore.QuerySnapshot
import com.google.firebase.firestore.Source

class FirebaseFirestoreGetEventLiveData(private val source: Source, private val query: Query) : LiveData<Event<DataOrException<QuerySnapshot, Exception>>>() {

    private var mQuery = query

    fun setQuery(query: Query) {
        mQuery = query
    }

    fun query() {
        mQuery.get(source).addOnCompleteListener {
            value = try {
                Event(DataOrException(it.result, it.exception))
            } catch (e: Exception) {
                Event(DataOrException(null, it.exception))
            }
        }
    }
}