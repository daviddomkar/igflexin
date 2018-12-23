package com.appapply.igflexin.livedata.firebase

import android.util.Log
import androidx.lifecycle.LiveData
import com.google.firebase.database.DataSnapshot
import com.google.firebase.database.DatabaseError
import com.google.firebase.database.FirebaseDatabase
import com.google.firebase.database.ValueEventListener
import org.koin.standalone.KoinComponent
import org.koin.standalone.inject

class FirebaseConnectionLiveData : LiveData<Boolean>(), KoinComponent {
    private val firebaseDatabase: FirebaseDatabase  by inject()

    private var fake = false

    init {
        firebaseDatabase.goOnline()
        Log.d("IGFlexin_presence", "Initialized")
        firebaseDatabase.getReference(".info/connected").addValueEventListener(object: ValueEventListener  {
            override fun onCancelled(error: DatabaseError) {}

            override fun onDataChange(snapshot: DataSnapshot) {
                var connected = snapshot.getValue(Boolean::class.java)
                Log.d("IGFlexin_presence", "Connected: " + connected!!)
                firebaseDatabase.goOnline()

                postValue(connected!!)
            }
        })
    }

    /*
    override fun onActive() {
        super.onActive()
    }

    override fun onInactive() {
        super.onInactive()
        firebaseAuth.removeAuthStateListener(listener)
    }*/
}