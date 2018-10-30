package com.appapply.igflexin.repositories

import android.util.Log.d
import androidx.lifecycle.LiveData
import androidx.lifecycle.Transformations
import com.appapply.igflexin.codes.StatusCode
import com.appapply.igflexin.livedata.firebase.FirebaseAuthLiveData
import com.appapply.igflexin.pojo.Resource
import com.appapply.igflexin.pojo.User

interface UserRepository {
    fun getUserLiveData() : LiveData<Resource<User>>
}

class FirebaseUserRepository(private val firebaseAuthLiveData: FirebaseAuthLiveData) : UserRepository {
    private val userLiveData = Transformations.map(firebaseAuthLiveData) { firebaseAuth ->
        if (firebaseAuth.currentUser != null && firebaseAuth.currentUser!!.email != null) {
            Resource(StatusCode.SUCCESS, User(firebaseAuth.currentUser!!.uid, firebaseAuth.currentUser!!.displayName, firebaseAuth.currentUser!!.email!!, firebaseAuth.currentUser!!.isEmailVerified))
        } else {
            Resource<User>(StatusCode.ERROR, null)
        }
    }

    override fun getUserLiveData(): LiveData<Resource<User>> {
        d("IGFlexin", "gotLiveData " + userLiveData.value.toString())
        return userLiveData
    }
}