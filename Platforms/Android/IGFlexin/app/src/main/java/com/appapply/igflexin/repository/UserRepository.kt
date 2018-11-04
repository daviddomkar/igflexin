package com.appapply.igflexin.repository

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.appapply.igflexin.common.Resource
import com.appapply.igflexin.common.StatusCode
import com.appapply.igflexin.model.User

interface UserRepository {
    val userLiveData: LiveData<Resource<User>>

    fun changeUser(user: User)
}

class FirebaseUserRepository : UserRepository {
    override val userLiveData: LiveData<Resource<User>>
        get() = TODO("not implemented") //To change initializer of created properties use File | Settings | File Templates.

    override fun changeUser(user: User) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }
}

class TestUserRepository : UserRepository {
    private val userMutableLiveData = MutableLiveData<Resource<User>>().also {
        it.value = Resource(StatusCode.SUCCESS, User("test", "test@test.test", "Test", true))
    }

    override val userLiveData: LiveData<Resource<User>>
        get() = userMutableLiveData

    override fun changeUser(user: User) {
        userMutableLiveData.value = Resource(StatusCode.SUCCESS, user)
    }
}