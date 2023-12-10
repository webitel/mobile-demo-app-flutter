package com.webitel.flutter_demo_app

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class WebitelPortalPlugin: FlutterPlugin, ActivityAware {
    private val PORTAL_CHANNEL = "webitel.com/portal"
    private val CALL_EVENT_CHANNEL = "webitel.com/calls"
    private val CHAT_EVENT_CHANNEL = "webitel.com/chat"

    private lateinit var eventChannel: EventChannel
    private lateinit var chatEventChannel: EventChannel
    private lateinit var channel: MethodChannel
    private lateinit var portal: WebitelPortal


    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        portal = WebitelPortal(binding.applicationContext)
        channel = MethodChannel(binding.binaryMessenger, PORTAL_CHANNEL)
        eventChannel = EventChannel(binding.binaryMessenger, CALL_EVENT_CHANNEL)
        chatEventChannel = EventChannel(binding.binaryMessenger, CHAT_EVENT_CHANNEL)
        eventChannel.setStreamHandler(portal.callListener)
        chatEventChannel.setStreamHandler(portal.chatListener)

        channel.setMethodCallHandler { call, result ->
            portal.methodCallHandler(call.method, call.arguments, result)
        }
    }


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }


    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        portal.setActivity(binding.activity)
    }


    override fun onDetachedFromActivityForConfigChanges() {
        portal.setActivity(null)
    }


    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        portal.setActivity(binding.activity)
    }


    override fun onDetachedFromActivity() {
        portal.setActivity(null)
    }
}