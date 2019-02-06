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
    private val connectedRef = firebaseDatabase.getReference(".info/connected")
    private val persistentRef = firebaseDatabase.getReference("persistance")

    init {
        Log.d("IGFlexin_presence", "Initialized")

        persistentRef.addValueEventListener(object: ValueEventListener  {
            override fun onCancelled(error: DatabaseError) {}

            override fun onDataChange(snapshot: DataSnapshot) {
                val connected = snapshot.getValue(Boolean::class.java)
                Log.d("IGFlexin_presence", "Connected: " + connected!!)

                postValue(connected)
            }
        })

        connectedRef.addValueEventListener(object: ValueEventListener  {
            override fun onCancelled(error: DatabaseError) {}

            override fun onDataChange(snapshot: DataSnapshot) {
                val connected = snapshot.getValue(Boolean::class.java)
                Log.d("IGFlexin_presence", "Connected: " + connected!!)

                postValue(connected)
            }
        })
    }
}