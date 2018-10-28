package com.appapply.igflexin.livedata.firebase

import androidx.lifecycle.LiveData
import com.appapply.igflexin.pojo.DataOrException
import com.google.firebase.firestore.*
import org.koin.standalone.KoinComponent
import org.koin.standalone.inject

typealias QuerySnapshotsOrException = DataOrException<QuerySnapshot?, FirebaseFirestoreException?>

class FirebaseFirestoreQueryLiveData(private val query: Query) : LiveData<QuerySnapshotsOrException>(), EventListener<QuerySnapshot>, KoinComponent {
    private val firebaseFirestore: FirebaseFirestore by inject()

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
        value = QuerySnapshotsOrException(querySnapshot, firestoreFirebaseException)
    }
}