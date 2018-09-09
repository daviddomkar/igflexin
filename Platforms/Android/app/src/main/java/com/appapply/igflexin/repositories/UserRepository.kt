package com.appapply.igflexin.repositories

import androidx.lifecycle.LiveData
import androidx.lifecycle.Transformations
import com.appapply.igflexin.livedata.firebase.FirebaseAuthLiveData
import com.appapply.igflexin.pojo.User
import com.google.firebase.auth.FirebaseAuth

interface UserRepository {
    fun getUser() : LiveData<User>
}

class FirebaseUserRepository(private val firebaseAuth: FirebaseAuth) : UserRepository {
    private val firebaseAuthLiveData: FirebaseAuthLiveData = FirebaseAuthLiveData()

    override fun getUser(): LiveData<User> {
        return Transformations.map(firebaseAuthLiveData) { firebaseAuth -> User(firebaseAuth.currentUser?.displayName, firebaseAuth.currentUser?.email)}
    }
}