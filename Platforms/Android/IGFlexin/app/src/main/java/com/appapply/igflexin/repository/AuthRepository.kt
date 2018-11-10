package com.appapply.igflexin.repository

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.appapply.igflexin.common.AuthStatusCode
import com.appapply.igflexin.common.StatusCode
import com.appapply.igflexin.events.Event
import com.google.android.gms.tasks.Task
import com.google.firebase.FirebaseNetworkException
import com.google.firebase.auth.*
import com.google.firebase.functions.FirebaseFunctions

interface AuthRepository {
    val authErrorLiveData: LiveData<Event<StatusCode>>
    val emailSentStatusLiveData: LiveData<Event<StatusCode>>

    fun signIn(email: String, password: String)
    fun signUp(name: String, email: String, password: String)
    fun signInWithCredential(authCredential: AuthCredential)
    fun signOut()

    fun sendVerificationEmail()
}

class FirebaseAuthRepository(private val firebaseAuth: FirebaseAuth, private val firebaseFunctions: FirebaseFunctions) : AuthRepository {
    private val authErrorMutableLiveData: MutableLiveData<Event<StatusCode>> = MutableLiveData()
    private val emailSentStatusMutableLiveData: MutableLiveData<Event<StatusCode>> = MutableLiveData()

    override val authErrorLiveData: LiveData<Event<StatusCode>>
        get() = authErrorMutableLiveData

    override val emailSentStatusLiveData: LiveData<Event<StatusCode>>
        get() = emailSentStatusMutableLiveData

    override fun signIn(email: String, password: String) {
        firebaseAuth.signInWithEmailAndPassword(email, password).addOnCompleteListener {
            handleSignInTask(it)
        }
    }

    override fun signUp(name: String, email: String, password: String) {
        firebaseAuth.createUserWithEmailAndPassword(email, password).addOnCompleteListener {
            handleSignUpTask(name, it)
        }
    }

    override fun signInWithCredential(authCredential: AuthCredential) {
        firebaseAuth.signInWithCredential(authCredential).addOnCompleteListener {
            handleSignInTask(it)
        }
    }

    override fun signOut() {
        firebaseAuth.signOut()
    }

    private fun handleSignUpTask(name: String, task: Task<AuthResult>) {
        if (handleSignInTask(task)) {

            val data = HashMap<String, String>()
            data["displayName"] = name

            firebaseFunctions.getHttpsCallable("updateDisplayName").call(data)
        }
    }

    private fun handleSignInTask(task: Task<AuthResult>) : Boolean {
        when {
            task.isSuccessful -> return true
            task.isCanceled -> authErrorMutableLiveData.value = Event(StatusCode.CANCELED)
            else -> when {
                task.exception is FirebaseAuthInvalidUserException -> {
                    val invalidUserException: FirebaseAuthInvalidUserException = task.exception as FirebaseAuthInvalidUserException

                    Log.d("IGFlexin", "jejda jako " + invalidUserException.errorCode)

                    when (invalidUserException.errorCode) {
                        "ERROR_USER_DISABLED" -> authErrorMutableLiveData.value = Event(AuthStatusCode.USER_DISABLED)
                        "ERROR_USER_NOT_FOUND " -> authErrorMutableLiveData.value = Event(AuthStatusCode.USER_NOT_FOUND)
                        "ERROR_EMAIL_ALREADY_IN_USE  " -> authErrorMutableLiveData.value = Event(AuthStatusCode.EMAIL_ALREADY_IN_USE)
                        "ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL" -> authErrorMutableLiveData.value = Event(AuthStatusCode.EXISTS_WITH_DIFFERENT_CREDENTIAL)
                        "ERROR_CREDENTIAL_ALREADY_IN_USE " -> authErrorMutableLiveData.value = Event(AuthStatusCode.CREDENTIAL_ALREADY_IN_USE)
                        else -> authErrorMutableLiveData.value = Event(StatusCode.ERROR)
                    }
                }
                task.exception is FirebaseAuthInvalidCredentialsException -> authErrorMutableLiveData.value = Event(AuthStatusCode.INVALID_CREDENTIALS)
                task.exception is FirebaseAuthUserCollisionException -> authErrorMutableLiveData.value = Event(AuthStatusCode.EMAIL_ALREADY_IN_USE)
                task.exception is FirebaseAuthWeakPasswordException -> authErrorMutableLiveData.value = Event(AuthStatusCode.WEAK_PASSWORD)
                task.exception is FirebaseNetworkException -> authErrorMutableLiveData.value = Event(StatusCode.NETWORK_ERROR)
                else -> authErrorMutableLiveData.value = Event(StatusCode.ERROR)
            }
        }

        return false
    }

    override fun sendVerificationEmail() {
        emailSentStatusMutableLiveData.value = Event(StatusCode.PENDING)
        firebaseAuth.currentUser!!.sendEmailVerification().addOnCompleteListener {
            if (it.isSuccessful) {
                emailSentStatusMutableLiveData.value = Event(StatusCode.SUCCESS)
            } else {
                if(it.exception != null && it.exception is FirebaseNetworkException)
                    emailSentStatusMutableLiveData.value = Event(StatusCode.NETWORK_ERROR)
                else
                    emailSentStatusMutableLiveData.value = Event(StatusCode.ERROR)
            }
        }
    }
}