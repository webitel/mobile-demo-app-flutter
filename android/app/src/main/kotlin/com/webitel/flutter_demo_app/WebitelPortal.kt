package com.webitel.flutter_demo_app

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.webitel.mobile_sdk.domain.Message
import com.webitel.mobile_sdk.domain.User
import io.flutter.plugin.common.MethodChannel


class WebitelPortal(private val context: Context) {
    val callListener = CallsStreamHandler(context)
    val chatListener = ChatStreamHandler(context)

    private var activity: Activity? = null
    private var _portal: PortalCustomerService? = null


    fun methodCallHandler(method: String, data: Any, result: MethodChannel.Result) {
        when (method) {
            "init" -> {
                val arg = data as Map<String,String>
                init(arg, result)
            }
            "setUser" -> {
                val arg = data as Map<String,String>
                setUser(arg, result)
            }
            "makeCall" -> {
                makeCall(result)
            }
            "disconnectCall" -> {
                disconnectCall(result)
            }
            "toggleMuteCall" -> {
                toggleMuteCall(result)
            }
            "getCallState" -> {
                sendCallState()
            }
            "toggleHoldCall" -> {
                toggleHoldCall(result)
            }
            "toggleLoudSpeaker" -> {
                toggleLoudSpeaker(result)
            }
            "sendDtmf" -> {
                val arg = data as Map<String,String>
                sendDtmf(arg, result)
            }
            "sendText" -> {
                val arg = data as Map<String,String>
                sendTextMessage(arg, result)
            }
            "getHistory" -> {
                val arg = data as Map<String,String>
                getHistory(arg, result)
            }
            "getUpdates" -> {
                val arg = data as Map<String,String>
                getUpdates(arg, result)
            }
        }
    }


    fun setActivity(activity: Activity?) {
        this.activity = activity
    }


    private fun init(arg: Map<String,String>, result: MethodChannel.Result) {
        val appToken = arg["app_token"]
            ?: return result.error("NOT_FOUND", "app_token - is required", null)
        val address: String = arg["address"]
            ?: return result.error("NOT_FOUND", "address - is required", null)

        portalService()?.init(
            token = appToken,
            address = address
        )
        result.success(true)
    }


    private fun setUser(arg: Map<String,String>, result: MethodChannel.Result) {
        val iss = arg["iss"]
            ?: return result.error("NOT_FOUND", "iss - is required", null)
        val sub = arg["sub"]
            ?: return result.error("NOT_FOUND", "sub - is required", null)
        val name = arg["name"]
            ?: return result.error("NOT_FOUND", "name - is required", null)

        /**
         * Optionals
         */
        val locale = arg["locale"] ?: ""
        val email = arg["email"] ?: ""
        val emailVerified = arg["emailVerified"].toBoolean()
        val phoneNumber = arg["phoneNumber"] ?: ""
        val phoneNumberVerified = arg["phoneNumberVerified"].toBoolean()

        val user = User.Builder(
            iss = iss,
            sub = sub,
            name = name
        )
            .locale(locale)
            .email(email)
            .emailVerified(emailVerified)
            .phoneNumber(phoneNumber)
            .phoneNumberVerified(phoneNumberVerified)
            .build()

        portalService()?.setUser(user)
        result.success(true)
    }


    private fun getUpdates(arg: Map<String, String>, result: MethodChannel.Result) {
        if (portalService()?.isInitialized() != true)
            return result.error(
                "NOT_INITIALIZED",
                "you need to call \"init\" first",
                null
            )

        val limit = arg["limit"]?.toIntOrNull() ?: 0
        val offset = arg["offset"]?.toLongOrNull() ?: 0

        portalService()?.getUpdates(
            PortalCustomerService.Params(limit, offset),
            chatListener
        ) { err, messages ->
            if (err != null) {
                result.error(
                    err.code.name,
                    err.message,
                    null
                )
            } else {
                chatListener.onMessages("getUpdates", messages?.reversed())
                result.success(messages?.size)
            }
        }
    }


    private fun getHistory(arg: Map<String, String>, result: MethodChannel.Result) {
        if (portalService()?.isInitialized() != true)
            return result.error(
                "NOT_INITIALIZED",
                "you need to call \"init\" first",
                null
            )

        val limit = arg["limit"]?.toIntOrNull() ?: 0
        val offset = arg["offset"]?.toLongOrNull() ?: 0

        portalService()?.getHistory(
            PortalCustomerService.Params(limit, offset),
            chatListener
        ) { err, messages ->
            if (err != null) {
                result.error(
                    err.code.name,
                    err.message,
                    null
                )
            } else {
                chatListener.onMessages("getHistory", messages)
                result.success(messages?.size)
            }
        }
    }


    private fun sendTextMessage(arg: Map<String, String>, result: MethodChannel.Result) {
        if (portalService()?.isInitialized() != true)
            return result.error(
                "NOT_INITIALIZED",
                "you need to call \"init\" first",
                null
            )

        val text = arg["text"]
            ?: return result.error("NOT_FOUND", "text - is required", null)

        portalService()?.sendMessage(
            chatListener,
            Message.options().withText(text)) {err, message ->
            if (err != null) {
                result.error(
                    err.code.name,
                    err.message,
                    null
                )
            } else {
                if (message != null)
                    chatListener.onMessages("onSent", listOf(message))
                result.success(null)
            }
        }
    }


    private fun makeCall(result: MethodChannel.Result) {
        if (portalService()?.isInitialized() != true)
            return result.error(
                "NOT_INITIALIZED",
                "you need to call \"init\" first",
                null
            )

        if(!checkAndRequestPermissions())
            return result.error(
                "PERMISSION_DENIED",
                "permission not found Manifest.permission.RECORD_AUDIO",
                null
            )

        portalService()?.makeCall(callListener) { err ->
            if (err != null) result.error(err.code.name, err.message, null)
            else result.success(true)
        }
    }


    private fun sendCallState() {
        portalService()?.getActiveCall { call ->
            callListener.sendCallState(call)
        }
    }


    private fun sendDtmf(arg: Map<String, String>, result: MethodChannel.Result) {
        val dtmf = arg["dtmf"]
            ?: return result.error(
                "NOT_FOUND",
                "dtmf - is required", null
            )

        if (dtmf.trim().isNotEmpty()) {
            val c = dtmf.trim().first().toString()
            portalService()?.sendDtmf(c) { err ->
                if (err != null) result.error(err.code.name, err.message, null)
                else result.success(true)
            }
        } else {
            return result.error(
                "NOT_FOUND",
                "dtmf - can not by empty",
                null
            )
        }
    }


    private fun disconnectCall(result: MethodChannel.Result) {
        portalService()?.disconnectCall { err ->
            if (err != null) result.error(err.code.name, err.message, null)
            else result.success(true)
        }
    }


    private fun toggleHoldCall(result: MethodChannel.Result) {
        portalService()?.toggleHoldCall { err ->
            if (err != null) result.error(err.code.name, err.message, null)
            else result.success(true)
        }
    }


    private fun toggleLoudSpeaker(result: MethodChannel.Result) {
        portalService()?.toggleLoudSpeaker { err ->
            if (err != null) result.error(err.code.name, err.message, null)
            else result.success(true)
        }
    }


    private fun toggleMuteCall(result: MethodChannel.Result) {
        portalService()?.toggleMuteCall { err ->
            if (err != null) result.error(err.code.name, err.message, null)
            else result.success(true)
        }
    }


    private fun portalService(): PortalCustomerService? {
        val p = _portal
        return if (p != null) p
        else {
            val a = activity
            if (a != null) {
                _portal = PortalCustomerService(a.application)
                _portal
            } else null
        }
    }


    private fun checkAndRequestPermissions(): Boolean {
        val recordAudio =
            ContextCompat.checkSelfPermission(context, Manifest.permission.RECORD_AUDIO)


        val listPermissionsNeeded: MutableList<String> = ArrayList()

        if (recordAudio != PackageManager.PERMISSION_GRANTED) {
            listPermissionsNeeded.add(Manifest.permission.RECORD_AUDIO)
        }

        if (listPermissionsNeeded.isNotEmpty()) {
            val a = activity
            if (a != null)
                ActivityCompat.requestPermissions(
                    a,
                    listPermissionsNeeded.toTypedArray(),
                    1
                )
            return false
        }
        return true
    }
}