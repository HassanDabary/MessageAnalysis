package com.example.hassan_dabary

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.net.Uri
import android.provider.Telephony
import com.google.gson.Gson

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.hassan_dabary/smsRetriever"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getAllSms") {
                    val smsList = getAllSms()
                    result.success(smsList)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun getAllSms(): String {
        val smsList = mutableListOf<Map<String, Any>>()

        val projection = arrayOf(Telephony.Sms.ADDRESS, Telephony.Sms.DATE, Telephony.Sms.BODY)
        val cursor = contentResolver.query(
            Uri.parse("content://sms/inbox"),
            projection,
            null,
            null,
            null
        )

        cursor?.use {
            val senderIndex = it.getColumnIndexOrThrow(Telephony.Sms.ADDRESS)
            val dateIndex = it.getColumnIndexOrThrow(Telephony.Sms.DATE)
            val bodyIndex = it.getColumnIndexOrThrow(Telephony.Sms.BODY)

            while (it.moveToNext()) {
                val sender = it.getString(senderIndex)
                val date = it.getLong(dateIndex)
                val body = it.getString(bodyIndex)

                val sms = mapOf(
                    "sender" to sender,
                    "date" to date,
                    "body" to body
                )

                smsList.add(sms)
            }
        }

        // Convert list of maps to a JSON string
        val gson = Gson()
        return gson.toJson(smsList)
    }
}
