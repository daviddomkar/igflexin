package com.appapply.igflexin.repository

import android.content.Intent
import com.appapply.igflexin.common.Resource
import com.appapply.igflexin.common.StatusCode
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.common.api.CommonStatusCodes
import com.google.firebase.auth.AuthCredential
import com.google.firebase.auth.GoogleAuthProvider

interface GoogleSignInRepository {
    fun getGoogleSignInIntent(): Intent
    fun getGoogleAuthCredential(data: Intent) : Resource<AuthCredential>
}

class GoogleSignInRepositoryImpl(private val googleSignInClient: GoogleSignInClient) : GoogleSignInRepository {

    override fun getGoogleSignInIntent(): Intent {
        return googleSignInClient.signInIntent
    }

    override fun getGoogleAuthCredential(data: Intent) : Resource<AuthCredential> {
        val task = GoogleSignIn.getSignedInAccountFromIntent(data)

        return try {
            val account = task.getResult(ApiException::class.java)
            Resource(StatusCode.SUCCESS, GoogleAuthProvider.getCredential(account?.idToken, null))
        } catch(e: ApiException) {
            when (e.statusCode) {
                CommonStatusCodes.NETWORK_ERROR -> Resource(StatusCode.NETWORK_ERROR, null)
                CommonStatusCodes.CANCELED -> Resource(StatusCode.CANCELED, null)
                12501 -> Resource(StatusCode.CANCELED, null)
                else -> Resource(StatusCode.ERROR, null)
            }
        }
    }
}