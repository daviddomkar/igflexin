package com.appapply.igflexin.repositories

import android.util.Log.d
import androidx.lifecycle.LiveData
import androidx.lifecycle.Transformations
import com.appapply.igflexin.livedata.firebase.FirebaseAuthLiveData
import com.appapply.igflexin.pojo.User
import com.google.firebase.auth.FirebaseAuth

interface UserRepository {
    fun getUserLiveData() : LiveData<User>
}

class FirebaseUserRepository(private val firebaseAuth: FirebaseAuth, private val firebaseAuthLiveData: FirebaseAuthLiveData) : UserRepository {
    private val userLiveData = Transformations.map(firebaseAuthLiveData) { firebaseAuth -> User(firebaseAuth.currentUser?.uid, firebaseAuth.currentUser?.displayName, firebaseAuth.currentUser?.email, firebaseAuth.currentUser?.isEmailVerified) }

    override fun getUserLiveData(): LiveData<User> {
        d("IGFlexin", "gotLiveData " + userLiveData.value.toString())
        return userLiveData
    }


}