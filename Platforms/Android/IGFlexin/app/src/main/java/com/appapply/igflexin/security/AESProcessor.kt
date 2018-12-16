import android.util.Base64
import android.util.Log
import java.security.MessageDigest

import javax.crypto.Cipher
import javax.crypto.spec.SecretKeySpec


object AESProcessor {

    fun encrypt(data: String, password_text: String): String {
        val key = generateKey(password_text)
        val c = Cipher.getInstance("AES/ECB/PKCS5Padding")
        c.init(Cipher.ENCRYPT_MODE, key)
        val encVal = c.doFinal(data.toByteArray(charset("UTF-8")))
        return Base64.encodeToString(encVal, Base64.DEFAULT)

    }

    fun decrypt(data: String, password_text: String): String {
        val key = generateKey(password_text)
        val c = Cipher.getInstance("AES/ECB/PKCS5Padding")
        c.init(Cipher.DECRYPT_MODE, key)
        val decodedvalue = Base64.decode(data, Base64.DEFAULT)
        val decvalue = c.doFinal(decodedvalue)
        return String(decvalue, Charsets.UTF_8)
    }

    private fun generateKey(password: String): SecretKeySpec {
        val digest = MessageDigest.getInstance("SHA-256")
        val bytes = password.toByteArray(charset("UTF-8"))
        digest.update(bytes, 0, bytes.size)
        val key = digest.digest()
        return SecretKeySpec(key, "AES")
    }
}