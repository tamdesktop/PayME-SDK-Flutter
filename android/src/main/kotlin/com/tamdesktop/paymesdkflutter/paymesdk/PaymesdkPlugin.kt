package com.tamdesktop.paymesdkflutter.paymesdk

import android.content.Context
import androidx.annotation.NonNull
import androidx.fragment.app.FragmentActivity

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject
import vn.payme.sdk.PayME
import vn.payme.sdk.enums.*
import vn.payme.sdk.model.Service
import java.text.DateFormat
import java.text.SimpleDateFormat
import java.util.*



/** PaymesdkPlugin */
class PaymesdkPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var activityPluginBinding: ActivityPluginBinding
    private lateinit var payme: PayME

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityPluginBinding = binding
    }

    override fun onDetachedFromActivityForConfigChanges() {
        TODO("Not yet implemented")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityPluginBinding = binding
    }

    override fun onDetachedFromActivity() {
        TODO("Not yet implemented")
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "paymesdk")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else if (call.method == "login") {
            login(call, result)
        } else if (call.method == "getAccountInfo") {
            getAccountInfo(call, result)
        } else if (call.method == "getSupportedServices") {
            getSupportedServices(call, result)
        } else if (call.method == "openWallet") {
            openWallet(call, result)
        } else if (call.method == "deposit") {
            deposit(call, result)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun login(@NonNull call: MethodCall, @NonNull result: Result) {
        // Extract args
        val userId = call.argument<String>("user_id")
        val phone = call.argument<String>("phone")
        val appToken = call.argument<String>("app_token")
        val publicKey = call.argument<String>("public_key")
        val privateKey = call.argument<String>("private_key")
        val secretKey = call.argument<String>("secret_key")
        val primaryColor = call.argument<String>("primary_color")
        val secondaryColor = call.argument<String>("secondary_color")
        val language = call.argument<String>("language")
        val envStr = call.argument<String>("env")

        // TODO: Check required args
        if (appToken == null || publicKey == null || privateKey == null || secretKey == null || primaryColor == null || secondaryColor == null) {
            result.error("MISSING_INFO", "", null)
            return
        }

        var lang = when (language) {
            "VN" -> LANGUAGES.VN
            "EN" -> LANGUAGES.EN
            else -> LANGUAGES.VN
        }

        var env = when (envStr) {
            "PRODUCTION" -> Env.PRODUCTION
            "SANDBOX" -> Env.SANDBOX
            "DEV" -> Env.DEV
            else -> Env.SANDBOX
        }

        // Init PayMe SDK
        val tz = TimeZone.getTimeZone("UTC")
        val df: DateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm'Z'")
        df.timeZone = tz
        val nowAsISO: String = df.format(Date())
        val dataExample = "{\"userId\":\"${userId}\",\"timestamp\":\"${nowAsISO}\",\"phone\":\"${phone}\"}"
        val connectToken = CryptoAES.encrypt(dataExample, secretKey).toString()

        val configColor = arrayOf<String>(primaryColor, secondaryColor)
        payme = PayME(context, appToken, publicKey, connectToken, privateKey, configColor, lang, env, false)

        // Login to PayME
        payme.login(onSuccess = { accountStatus: AccountStatus ->
            when (accountStatus) {
                AccountStatus.NOT_ACTIVATED -> {
                    //Tài khoản chưa kich hoạt
                    println("NOT_ACTIVATED")
                    result.success("NOT_ACTIVATED")
                }
                AccountStatus.NOT_KYC -> {
                    //Tài khoản chưa định danh
                    println("NOT_KYC")
                    result.success("NOT_KYC")
                }
                AccountStatus.KYC_APPROVED -> {
                    //Tài khoản đã định danh
                    println("KYC_APPROVED")
                    result.success("KYC_APPROVED")
                }
                else -> {
                    result.success("")
                }
            }

        },
            onError = { jsonObject: JSONObject?, code: Int, message: String? ->
//                PayME.showError(message)
                println(message)
                result.error(code.toString(), message, jsonObject)
            }
        )


    }

    private fun getAccountInfo(@NonNull call: MethodCall, @NonNull result: Result){
        payme.getAccountInfo(onSuccess = { data: JSONObject ->
                result.success(data)
            },
            onError = { jsonObject: JSONObject?, code: Int, message: String? ->
                println(message)
                result.error(code.toString(), message, jsonObject)
            }
        )
    }

    private fun getSupportedServices(@NonNull call: MethodCall, @NonNull result: Result){
        payme.getSupportedServices(onSuccess = { arrService: ArrayList<Service>? ->
                    var list = arrayListOf<Map<String, Any?>>()
                    arrService?.forEach { service: Service ->
                        list.add(mapOf(
                            "code" to service.code,
                            "description" to service.description,
                            "disable" to service.disable,
                            "enable" to service.enable
                        ))
                    }
                    result.success(list)
                },
                onError = { jsonObject: JSONObject?, code: Int, message: String? ->
                    println(message)
                    result.error(code.toString(), message, jsonObject)
                }
        )
    }

    private fun openWallet(@NonNull call: MethodCall, @NonNull result: Result){
        var fragment = activityPluginBinding.activity as FragmentActivity
        payme.openWallet(fragment.supportFragmentManager,
                onSuccess = { data: JSONObject? ->
                    result.success(data)
                },
                onError = { jsonObject: JSONObject?, code: Int, message: String? ->
                    println(message)
                    result.error(code.toString(), message, jsonObject)
                }
        )
    }

    private fun deposit(@NonNull call: MethodCall, @NonNull result: Result){
        val amount = call.argument<Int>("amount")
        val closeDepositResult = call.argument<Boolean>("close_deposit_result")
        if(amount==null || closeDepositResult == null){
            result.error("MISSING_INFO", "", null)
            return
        }
        var fragment = activityPluginBinding.activity as FragmentActivity
        payme.deposit(fragment.supportFragmentManager,
                amount,
                closeDepositResult,
                onSuccess = { data: JSONObject? ->
                    result.success(data)
                },
                onError = { jsonObject: JSONObject?, code: Int, message: String? ->
                    println(message)
                    result.error(code.toString(), message, jsonObject)
                }
        )
    }

}
