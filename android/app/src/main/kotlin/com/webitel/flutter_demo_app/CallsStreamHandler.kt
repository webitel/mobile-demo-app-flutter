package com.webitel.flutter_demo_app

import android.content.Context
import android.os.Handler
import android.util.Log
import com.webitel.mobile_sdk.domain.Call
import com.webitel.mobile_sdk.domain.CallState
import com.webitel.mobile_sdk.domain.CallStateListener
import com.webitel.mobile_sdk.domain.Error
import io.flutter.plugin.common.EventChannel


class CallsStreamHandler(private val context: Context): EventChannel.StreamHandler,
    CallStateListener {

    private var callsEvents: EventChannel.EventSink? = null
    private val handler = Handler(context.mainLooper)


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        if (events == null) return
        callsEvents = events
    }


    override fun onCancel(arguments: Any?) {
        callsEvents = null
    }


    override fun onCallStateChanged(call: Call, oldState: List<CallState>) {
        sendEvent(call, oldState)
    }


    override fun onCreateCall(call: Call) {
        sendEvent(call, null)
    }


    override fun onCreateCallFailed(e: Error) {
        Log.e("CallFailed", e.message)
        handler.post {
            callsEvents?.error(e.code.name, e.message, null)
        }
    }


    fun sendCallState(call: Call?) {
        call?.addListener(this)
        sendEvent(call, null)
    }


    private fun sendEvent(call: Call?, oldState: List<CallState>?) {
        val stringStringMap: MutableMap<String, Any> = HashMap()

        if (call == null) {
            stringStringMap["callState"] = listOf<String>()
            pushSuccess(stringStringMap)
            return
        }

        val d = arrayListOf<String>()
        call.state.forEach {
            d.add(it.name)
        }

        val old = arrayListOf<String>()
        oldState?.forEach {
            old.add(it.name)
        }

        stringStringMap["callState"] = d.toList()
        stringStringMap["oldState"] = old.toList()

        stringStringMap["id"] = call.id
        stringStringMap["answeredAt"] = call.answeredAt
        stringStringMap["dtmfHistory"] = call.dtmfHistory

        pushSuccess(stringStringMap)
    }


    private fun pushSuccess(value: MutableMap<String, Any>) {
        handler.post {
            callsEvents?.success(value)
        }
    }
}