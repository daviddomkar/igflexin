package com.appapply.igflexin.livedata.firebase

import androidx.lifecycle.LiveData
import com.appapply.igflexin.common.DataOrException
import com.google.firebase.firestore.*

class FirebaseFirestoreQueryLiveData(private val metadataChanges: MetadataChanges, private val query: Query?) : LiveData<DataOrException<QuerySnapshot?, Exception?>>(), EventListener<QuerySnapshot> {

    private var listenerRegistration: ListenerRegistration? = null

    private var mQuery = query

    fun setQuery(query: Query) {
        mQuery = query
        listenerRegistration?.remove()
        listenerRegistration = mQuery?.addSnapshotListener(metadataChanges, this)
    }

    override fun onActive() {
        super.onActive()
        listenerRegistration = mQuery?.addSnapshotListener(metadataChanges, this)
    }

    override fun onInactive() {
        super.onInactive()
        listenerRegistration?.remove()
    }

    override fun onEvent(querySnapshot: QuerySnapshot?, firestoreFirebaseException: FirebaseFirestoreException?) {
        value = DataOrException(querySnapshot, firestoreFirebaseException)
    }
}