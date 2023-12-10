package com.webitel.flutter_demo_app

import android.content.Context
import android.os.Handler
import com.webitel.mobile_sdk.domain.DialogListener
import com.webitel.mobile_sdk.domain.Message
import io.flutter.plugin.common.EventChannel


class ChatStreamHandler(context: Context)
    : EventChannel.StreamHandler, DialogListener {

    private var chatEvents: EventChannel.EventSink? = null
    private val handler = Handler(context.mainLooper)


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        if (events == null) return
        chatEvents = events
    }


    override fun onCancel(arguments: Any?) {
        chatEvents = null
    }


    override fun onMessageAdded(message: Message) {
        sendEvent("onReceive", arrayListOf(message))
    }


    fun onMessages(method: String, messages: List<Message>?) {
        sendEvent(method, messages)
    }


    private fun sendEvent(method: String, messages: List<Message>?) {
        val result: MutableMap<String, Any> = HashMap()
        val d = arrayListOf<MutableMap<String, Any>>()

        messages?.forEach {
            val m: MutableMap<String, Any> = HashMap()
            m["id"] = it.id
            m["text"] = it.text ?: ""
            m["isIncoming"] = it.isIncoming
            m["sentAt"] = it.sentAt
            m["from"] = it.from.name
            d.add(m)
        }

        result["messages"] = d.toList()
        result["method"] = method

        pushSuccess(result)
    }


    private fun pushSuccess(value: MutableMap<String, Any>) {
        handler.post {
            chatEvents?.success(value)
        }
    }
}