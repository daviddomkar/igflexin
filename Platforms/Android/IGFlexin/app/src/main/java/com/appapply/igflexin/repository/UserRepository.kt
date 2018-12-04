package com.appapply.igflexin.repository

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.Transformations
import com.appapply.igflexin.common.Resource
import com.appapply.igflexin.common.StatusCode
import com.appapply.igflexin.livedata.firebase.FirebaseAuthStateLiveData
import com.appapply.igflexin.model.User

interface UserRepository {
    val userLiveData: LiveData<Resource<User>>

    //fun changeUser(user: User)
}

class FirebaseUserRepository(private val firebaseAuthStateLiveData: FirebaseAuthStateLiveData) : UserRepository {

    override val userLiveData: LiveData<Resource<User>>
        get() = Transformations.map(firebaseAuthStateLiveData) {
            if (it.currentUser != null) {
                return@map Resource(StatusCode.SUCCESS, User(it.currentUser!!.uid, it.currentUser!!.email!!, it.currentUser!!.displayName, it.currentUser!!.isEmailVerified))
            } else {
                return@map Resource<User>(StatusCode.ERROR, null)
            }
        }
}

class TestUserRepository : UserRepository {
    private val userMutableLiveData = MutableLiveData<Resource<User>>().also {
        // it.value = Resource(StatusCode.SUCCESS, User("test", "test@test.test", "Test", false))
        it.value = Resource(StatusCode.ERROR, null)
    }

    override val userLiveData: LiveData<Resource<User>>
        get() = userMutableLiveData

    /*
    override fun changeUser(user: User) {
        userMutableLiveData.value = Resource(StatusCode.SUCCESS, user)
    }*/
}