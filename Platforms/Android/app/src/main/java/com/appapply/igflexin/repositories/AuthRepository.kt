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
import com.google.firebase.functions.FirebaseFunctions

interface AuthRepository {
    fun getSignedInLiveData(): LiveData<Boolean>
    fun getAuthStatusLiveData(): LiveData<Event<StatusCode>>
    fun getVerificationEmailStatusLiveData(): LiveData<StatusCode>

    fun signIn(email: String, password: String)
    fun signUp(name: String, email: String, password: String)
    fun signInWithCredential(credential: AuthCredential)
    fun sendVerificationEmail()
    fun signOut()
}

class FirebaseAuthRepository(private val firebaseAuth: FirebaseAuth, private val firebaseFunctions: FirebaseFunctions): AuthRepository {
    private val firebaseAuthLiveData: FirebaseAuthLiveData = FirebaseAuthLiveData()
    private val authStatusLiveData: MutableLiveData<Event<StatusCode>> = MutableLiveData()
    private val verificationEmailStatusLiveData: MutableLiveData<StatusCode> = MutableLiveData()

    override fun getSignedInLiveData() : LiveData<Boolean> {
        return Transformations.map(firebaseAuthLiveData) { firebaseAuth -> firebaseAuth.currentUser != null}
    }

    override fun getAuthStatusLiveData(): LiveData<Event<StatusCode>> {
        return authStatusLiveData
    }

    override fun getVerificationEmailStatusLiveData(): LiveData<StatusCode> {
        return verificationEmailStatusLiveData
    }

    override fun signIn(email: String, password: String) {
        firebaseAuth.signInWithEmailAndPassword(email, password).addOnCompleteListener {
            if (handleSignInTask(it)) authStatusLiveData.value = Event(StatusCode.SUCCESS)
        }
    }

    override fun signUp(name: String, email: String, password: String) {
        firebaseAuth.createUserWithEmailAndPassword(email, password).addOnCompleteListener { task ->
            handleSignUpTask(name, task)
        }
    }

    override fun signInWithCredential(credential: AuthCredential) {
        firebaseAuth.signInWithCredential(credential).addOnCompleteListener {
            if (handleSignInTask(it)) authStatusLiveData.value = Event(StatusCode.SUCCESS)
        }
    }

    override fun sendVerificationEmail() {
        verificationEmailStatusLiveData.value = StatusCode.PENDING
        firebaseAuth.currentUser?.sendEmailVerification()?.addOnCompleteListener {
            if(it.isSuccessful) {
                verificationEmailStatusLiveData.value = StatusCode.SUCCESS
            } else {
                verificationEmailStatusLiveData.value = StatusCode.ERROR
            }
        }
    }

    override fun signOut() {
        firebaseAuth.signOut()
    }

    private fun handleSignUpTask(name: String, task: Task<AuthResult>) {
        if (handleSignInTask(task)) {

            val data = HashMap<String, String>()
            data["displayName"] = name

            firebaseFunctions.getHttpsCallable("updateDisplayName").call(data).addOnCompleteListener {
                authStatusLiveData.value = Event(StatusCode.SUCCESS)
            }
        }
    }

    private fun handleSignInTask(task: Task<AuthResult>) : Boolean {
        when {
            task.isSuccessful -> return true
            task.isCanceled -> authStatusLiveData.value = Event(StatusCode.CANCELED)
            else -> when {
                task.exception is FirebaseAuthInvalidUserException -> {
                    val invalidUserException: FirebaseAuthInvalidUserException = task.exception as FirebaseAuthInvalidUserException

                    when (invalidUserException.errorCode) {
                        "ERROR_USER_DISABLED" -> authStatusLiveData.value = Event(AuthStatusCode.USER_DISABLED)
                        "ERROR_USER_NOT_FOUND " -> authStatusLiveData.value = Event(AuthStatusCode.USER_NOT_FOUND)
                        "ERROR_EMAIL_ALREADY_IN_USE  " -> authStatusLiveData.value = Event(AuthStatusCode.EMAIL_ALREADY_IN_USE)
                        "ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL" -> authStatusLiveData.value = Event(AuthStatusCode.EXISTS_WITH_DIFFERENT_CREDENTIAL)
                        "ERROR_CREDENTIAL_ALREADY_IN_USE " -> authStatusLiveData.value = Event(AuthStatusCode.CREDENTIAL_ALREADY_IN_USE)
                        else -> authStatusLiveData.value = Event(StatusCode.ERROR)
                    }
                }
                task.exception is FirebaseAuthInvalidCredentialsException -> authStatusLiveData.value = Event(AuthStatusCode.INVALID_CREDENTIALS)
                task.exception is FirebaseAuthUserCollisionException -> authStatusLiveData.value = Event(AuthStatusCode.EMAIL_ALREADY_IN_USE)
                task.exception is FirebaseAuthWeakPasswordException -> authStatusLiveData.value = Event(AuthStatusCode.WEAK_PASSWORD)
                else -> authStatusLiveData.value = Event(StatusCode.ERROR)
            }
        }

        return false
    }
}