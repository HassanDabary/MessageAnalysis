package com.example.hassan_dabary
import android.content.ContentResolver
import android.provider.Telephony
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Future
import android.net.Uri

class SmsRetriever(private val contentResolver: ContentResolver) : MethodChannel.MethodCallHandler {

    companion object {
        private const val METHOD_GET_ALL_SMS = "getAllSms"
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            METHOD_GET_ALL_SMS -> {
                val smsList = getAllSms()
                result.success(smsList)
            }
            else -> result.notImplemented()
        }
    }

    private fun getAllSms(): List<Map<String, Any>> {
        val smsList = mutableListOf<Map<String, Any>>()

        val projection = arrayOf(Telephony.Sms.BODY, Telephony.Sms.ADDRESS, Telephony.Sms.DATE)
        val uri = Uri.parse("content://sms/inbox")
        val cursor = contentResolver.query(uri, projection, null, null, null)

        cursor?.use {
            val bodyIndex = it.getColumnIndexOrThrow(Telephony.Sms.BODY)
            val addressIndex = it.getColumnIndexOrThrow(Telephony.Sms.ADDRESS)
            val dateIndex = it.getColumnIndexOrThrow(Telephony.Sms.DATE)
            while (it.moveToNext()) {
                val body = it.getString(bodyIndex)
                val address = it.getString(addressIndex)
                val date = it.getLong(dateIndex)
                val smsData = mapOf("body" to body, "sender" to address, "date" to date)
                smsList.add(smsData)
            }
        }

        println(smsList)
        return smsList

    }
}
