package com.appapply.igflexin.repositories

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.Transformations
import com.appapply.igflexin.codes.AuthStatusCode
import com.appapply.igflexin.codes.StatusCode
import com.appapply.igflexin.events.Event

import com.appapply.igflexin.livedata.firebase.FirebaseAuthLiveData
import com.appapply.igflexin.pojo.User
import com.google.android.gms.tasks.Task
import com.google.firebase.auth.*

interface AuthRepository {
    fun getSignedInLiveData(): LiveData<Boolean>
    fun getAuthStatusLiveData(): LiveData<Event<StatusCode>>
    fun getUser() : LiveData<User>

    fun signIn(email: String, password: String)
    fun signUp(name: String, email: String, password: String)
    fun signInWithCredential(credential: AuthCredential)
    fun signOut()
}

class FirebaseAuthRepository(private val firebaseAuth: FirebaseAuth): AuthRepository {
    private val firebaseAuthLiveData: FirebaseAuthLiveData = FirebaseAuthLiveData()
    private val authStatusLiveData: MutableLiveData<Event<StatusCode>> = MutableLiveData()

    override fun getSignedInLiveData() : LiveData<Boolean> {
        return Transformations.map(firebaseAuthLiveData) { firebaseAuth -> firebaseAuth.currentUser != null}
    }

    override fun getAuthStatusLiveData(): LiveData<Event<StatusCode>> {
        return authStatusLiveData
    }

    // TODO Move to UserRepository
    override fun getUser(): LiveData<User> {
        return Transformations.map(firebaseAuthLiveData) { firebaseAuth -> User(firebaseAuth.currentUser?.displayName, firebaseAuth.currentUser?.email)}
    }

    override fun signIn(email: String, password: String) {
        firebaseAuth.signInWithEmailAndPassword(email, password).addOnCompleteListener {
            handleSignInTask(it)
        }
    }

    override fun signUp(name: String, email: String, password: String) {
        firebaseAuth.createUserWithEmailAndPassword(email, password).addOnCanceledListener {
            authStatusLiveData.value = Event(StatusCode.CANCELED)
        }.addOnSuccessListener {
            // TODO add name to account
        }
    }

    override fun signInWithCredential(credential: AuthCredential) {
        firebaseAuth.signInWithCredential(credential).addOnCompleteListener {
            handleSignInTask(it)
        }
    }

    override fun signOut() {
        firebaseAuth.signOut()
    }

    private fun handleSignInTask(task: Task<AuthResult>) {
        if(task.isSuccessful) {
            authStatusLiveData.value = Event(StatusCode.SUCCESS)
        } else if (task.isCanceled) {
            authStatusLiveData.value = Event(StatusCode.CANCELED)
        } else {
            if(task.exception is FirebaseAuthInvalidUserException) {
                val invalidUserException: FirebaseAuthInvalidUserException = task.exception as FirebaseAuthInvalidUserException

                when (invalidUserException.errorCode) {
                    "ERROR_USER_DISABLED" -> {
                        authStatusLiveData.value = Event(AuthStatusCode.USER_DISABLED)
                    }
                    "ERROR_USER_NOT_FOUND " -> {
                        authStatusLiveData.value = Event(AuthStatusCode.USER_NOT_FOUND)
                    }
                    "ERROR_EMAIL_ALREADY_IN_USE  " -> {
                        authStatusLiveData.value = Event(AuthStatusCode.EMAIL_ALREADY_IN_USE)
                    }
                    "ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL" -> {
                        authStatusLiveData.value = Event(AuthStatusCode.EXISTS_WITH_DIFFERENT_CREDENTIAL)
                    }
                    "ERROR_CREDENTIAL_ALREADY_IN_USE " -> {
                        authStatusLiveData.value = Event(AuthStatusCode.CREDENTIAL_ALREADY_IN_USE)
                    } else -> {
                        authStatusLiveData.value = Event(StatusCode.ERROR)
                    }
                }
            } else if (task.exception is FirebaseAuthInvalidCredentialsException) {
                authStatusLiveData.value = Event(AuthStatusCode.INVALID_CREDENTIALS)
            } else if (task.exception is FirebaseAuthUserCollisionException ) {
                authStatusLiveData.value = Event(AuthStatusCode.EMAIL_ALREADY_IN_USE)
            } else if (task.exception is FirebaseAuthWeakPasswordException ) {
                authStatusLiveData.value = Event(AuthStatusCode.WEAK_PASSWORD)
            } else {
                authStatusLiveData.value = Event(StatusCode.ERROR)
            }
        }
    }
}