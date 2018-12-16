package com.appapply.igflexin.security

import android.content.Context
import android.os.Build
import android.util.Log

class UserKeyManager(private val context: Context) {

    private val encryptor = Encryptor()
    private val decryptor = Decryptor()

    private val preferences = context.getSharedPreferences("keys", Context.MODE_PRIVATE)

    fun saveKey(uid: String, key: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if(encryptor.encryptText(uid, key) != null) {
                Log.d("IGFlexin_saveKey", "success")
            } else {
                Log.d("IGFlexin_saveKey", "failure")
            }
        } else {
            val editor = preferences.edit()
            editor.putString(uid, key)
            editor.apply()
        }

        Log.d("IGFlexin_keyManager", "Save key - UID: $uid Key: $key")
    }

    fun retrieveKey(uid: String): String {

        var key = "none"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            encryptor.getIv()?.let { bytes ->
                encryptor.getEncryption()?.let {
                    key = decryptor.decryptData(uid, it, bytes)
                }
            }
        } else {
            key = preferences.getString(uid, "none")
        }

        Log.d("IGFlexin_keyManager", "Retrieve key - UID: $uid Key: $key")

        return key
    }
}