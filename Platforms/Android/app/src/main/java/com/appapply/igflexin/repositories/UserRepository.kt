package com.appapply.igflexin.repositories

import androidx.lifecycle.LiveData
import com.appapply.igflexin.pojo.User

interface UserRepository {
    fun getUser() : LiveData<User>
}