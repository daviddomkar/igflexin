package com.appapply.igflexin.livedata.firebase

import androidx.lifecycle.LiveData
import com.appapply.igflexin.pojo.DataOrException
import com.google.firebase.firestore.*
import org.koin.standalone.KoinComponent
import org.koin.standalone.inject

typealias QuerySnapshotOFirestoreException = DataOrException<QuerySnapshot?, FirebaseFirestoreException?>

class FirebaseFirestoreQueryLiveData(private val query: Query) : LiveData<QuerySnapshotOFirestoreException>(), EventListener<QuerySnapshot>, KoinComponent {

    private var listenerRegistration: ListenerRegistration? = null

    override fun onActive() {
        super.onActive()
        listenerRegistration = query.addSnapshotListener(MetadataChanges.INCLUDE, this)
    }

    override fun onInactive() {
        super.onInactive()
        listenerRegistration?.remove()
    }

    override fun onEvent(querySnapshot: QuerySnapshot?, firestoreFirebaseException: FirebaseFirestoreException?) {
        value = QuerySnapshotOFirestoreException(querySnapshot, firestoreFirebaseException)
    }
}