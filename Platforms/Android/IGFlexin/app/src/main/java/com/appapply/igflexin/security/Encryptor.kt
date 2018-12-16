package com.appapply.igflexin.security

import android.os.Build
import android.security.keystore.KeyProperties
import android.security.keystore.KeyGenParameterSpec
import androidx.annotation.RequiresApi
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey

class Encryptor {

    private val TRANSFORMATION = "AES/GCM/NoPadding"
    private val ANDROID_KEY_STORE = "AndroidKeyStore"

    private var encryption: ByteArray? = null
    private var iv: ByteArray? = null

    @RequiresApi(Build.VERSION_CODES.M)
    fun encryptText(alias: String, textToEncrypt: String): ByteArray? {

        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.ENCRYPT_MODE, getSecretKey(alias))

        iv = cipher.iv

        encryption = cipher.doFinal(textToEncrypt.toByteArray(Charsets.UTF_8))
        return encryption
    }

    @RequiresApi(Build.VERSION_CODES.M)
    private fun getSecretKey(alias: String): SecretKey {

        val keyGenerator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, ANDROID_KEY_STORE)

        keyGenerator.init(
            KeyGenParameterSpec.Builder(alias, KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT)
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .build()
        )

        return keyGenerator.generateKey()
    }

    fun getEncryption(): ByteArray? {
        return encryption
    }

    fun getIv(): ByteArray? {
        return iv
    }
}