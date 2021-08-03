package com.tamdesktop.paymesdkflutter.paymesdk

import android.util.Base64
import javax.crypto.Cipher
import javax.crypto.SecretKey
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.SecretKeySpec


object CryptoAES {
    //    public static String exampleKey ="Ge13YEobKVPAxEb1y8DYd5BpwFhSzlMaI5oK0/umFFhdn1ZK/chcRfMjjqUYadTwMR1SwjSK1Y+vcMaJ/5dkFg==";
    //    public static String privateKey= "3zA9HDejj1GnyVK0";
    var ivbyte = byteArrayOf(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    fun encrypt(input: String, key: String): String? {
        try {
            val bytes = input.toByteArray()
            val ciper = Cipher.getInstance("AES/CBC/PKCS5Padding")
            val iv = IvParameterSpec(ivbyte, 0, ciper.blockSize)
            val secret: SecretKey = SecretKeySpec(key.toByteArray(), "AES")
            ciper.init(Cipher.ENCRYPT_MODE, secret, iv)
            val result = ciper.doFinal(bytes)
            return Base64.encodeToString(result, Base64.NO_WRAP)
        } catch (e: Exception) {
            println(e)
        }
        return null
    }
}
