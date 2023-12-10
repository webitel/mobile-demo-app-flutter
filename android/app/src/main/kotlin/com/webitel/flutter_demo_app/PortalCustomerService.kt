package com.webitel.flutter_demo_app

import android.app.Application
import android.util.Log
import com.webitel.mobile_sdk.domain.Call
import com.webitel.mobile_sdk.domain.CallStateListener
import com.webitel.mobile_sdk.domain.CallbackListener
import com.webitel.mobile_sdk.domain.ChatClient
import com.webitel.mobile_sdk.domain.Code
import com.webitel.mobile_sdk.domain.Dialog
import com.webitel.mobile_sdk.domain.DialogListener
import com.webitel.mobile_sdk.domain.Error
import com.webitel.mobile_sdk.domain.HistoryRequest
import com.webitel.mobile_sdk.domain.LoginListener
import com.webitel.mobile_sdk.domain.Message
import com.webitel.mobile_sdk.domain.MessageCallbackListener
import com.webitel.mobile_sdk.domain.PortalClient
import com.webitel.mobile_sdk.domain.Session
import com.webitel.mobile_sdk.domain.User
import com.webitel.mobile_sdk.domain.VoiceClient

internal class PortalCustomerService(private val application: Application) {
    private var user: User? = null
    private var PORTAL_CLIENT = ""
    private var ADDRESS = ""

    private var _portalClient: PortalClient? = null
    private var _chatClient: ChatClient? = null
    private var _serviceDialog: Dialog? = null

    @Synchronized
    fun init(token: String, address: String) {
        if (_portalClient == null) {
            createClient(token = token, address = address)

            PORTAL_CLIENT = token
            ADDRESS = address

        } else {
            if (PORTAL_CLIENT == token && ADDRESS == address) return

            createClient(token = token, address = address)
            PORTAL_CLIENT = token
            ADDRESS = address
        }
    }


    fun isInitialized(): Boolean {
        return _portalClient != null
    }


    fun getUpdates(params: Params, listener: DialogListener,
                   callback: (Error?, List<Message>?) -> Unit) {
        if (user == null) {
            callback(
                Error(
                    "you need to call setUser first",
                    Code.NOT_FOUND
                ), null
            )
            return
        }

        if (_chatClient == null || _serviceDialog == null) {
            initChatControllerAndLogin(listener) {
                if (it != null) {
                    callback(it, null)
                } else {
                    getUpdatesAndLogin(params, listener, callback)
                }
            }
        } else {
            getUpdatesAndLogin(params, listener, callback)
        }
    }


    fun getHistory(params: Params, listener: DialogListener,
                   callback: (Error?, List<Message>?) -> Unit) {
        if (user == null) {
            callback(
                Error(
                    "you need to call setUser first",
                    Code.NOT_FOUND
                ), null
            )
            return
        }

        if (_chatClient == null || _serviceDialog == null) {
            initChatControllerAndLogin(listener) {
                if (it != null) {
                    callback(it, null)
                } else {
                    getHistoryAndLogin(params, listener, callback)
                }
            }
        } else {
            getHistoryAndLogin(params, listener, callback)
        }
    }


    fun sendMessage(listener: DialogListener,
                    message: Message.options,
                    callback: (Error?, Message?) -> Unit) {
        if (user == null) {
            callback(
                Error(
                    "you need to call setUser first",
                    Code.NOT_FOUND
                ), null
            )
            return
        }

        if (_chatClient == null || _serviceDialog == null) {
            initChatControllerAndLogin(listener) {
                if (it != null) {
                    callback(it, null)
                } else {
                    sendAndLogin(listener, message, callback)
                }
            }
        } else {
            sendAndLogin(listener, message, callback)
        }
    }


    fun makeCall(listener: CallStateListener, callback: (Error?) -> Unit) {
        if (user == null) {
            callback(
                Error(
                    "you need to call setUser first",
                    Code.NOT_FOUND
                )
            )
            return
        }

        _portalClient?.getVoiceClient(object : CallbackListener<VoiceClient> {

            override fun onError(e: Error) {
                if (e.code == Code.UNAUTHENTICATED) {
                    login { err ->
                        if (err != null) {
                            callback(err)
                            return@login
                        }

                        makeCallAgan(listener, callback)
                    }
                } else {
                    callback(e)
                }
            }

            override fun onSuccess(t: VoiceClient) {
                t.makeCall(listener)
                callback(null)
            }
        })
    }


    fun getActiveCall(callback: (Call?) -> Unit) {
        _portalClient?.getVoiceClient(object : CallbackListener<VoiceClient> {
            override fun onError(e: Error) {
                Log.e("getActiveCall", e.message)
                callback(null)
            }

            override fun onSuccess(t: VoiceClient) {
                callback(t.activeCall)
            }
        })
    }


    fun disconnectCall(callback: (Error?) -> Unit) {
        _portalClient?.getVoiceClient(object : CallbackListener<VoiceClient> {
            override fun onError(e: Error) {
                callback(e)
            }

            override fun onSuccess(t: VoiceClient) {
                val res = if (t.activeCall != null) null
                else Error("active call not found", Code.NOT_FOUND)
                t.activeCall?.disconnect()
                callback(res)
            }
        })
    }


    fun sendDtmf(dtmf: String, callback: (Error?) -> Unit) {
        _portalClient?.getVoiceClient(object : CallbackListener<VoiceClient> {
            override fun onError(e: Error) {
                callback(e)
            }

            override fun onSuccess(t: VoiceClient) {
                val res = if (t.activeCall != null) null
                else Error("active call not found", Code.NOT_FOUND)
                t.activeCall?.sendDigits(dtmf)
                callback(res)
            }
        })
    }


    fun toggleHoldCall(callback: (Error?) -> Unit) {
        _portalClient?.getVoiceClient(object : CallbackListener<VoiceClient> {
            override fun onError(e: Error) {
                callback(e)
            }

            override fun onSuccess(t: VoiceClient) {
                val res = if (t.activeCall != null) null
                else Error("active call not found", Code.NOT_FOUND)
                t.activeCall?.toggleHold()
                callback(res)
            }
        })
    }


    fun toggleLoudSpeaker(callback: (Error?) -> Unit) {
        _portalClient?.getVoiceClient(object : CallbackListener<VoiceClient> {
            override fun onError(e: Error) {
                callback(e)
            }

            override fun onSuccess(t: VoiceClient) {
                val res = if (t.activeCall != null) null
                else Error("active call not found", Code.NOT_FOUND)
                t.activeCall?.toggleLoudspeaker()
                callback(res)
            }
        })
    }

    fun toggleMuteCall(callback: (Error?) -> Unit) {
        _portalClient?.getVoiceClient(object : CallbackListener<VoiceClient> {
            override fun onError(e: Error) {
                callback(e)
            }

            override fun onSuccess(t: VoiceClient) {
                val res = if (t.activeCall != null) null
                else Error("active call not found", Code.NOT_FOUND)
                t.activeCall?.toggleMute()
                callback(res)
            }
        })
    }


    fun setUser(u: User) {
        user = u
    }


    private fun getUpdatesAndLogin(params: Params,
                                   listener: DialogListener,
                                   callback: (Error?, List<Message>?) -> Unit) {
        val s = object: CallbackListener<List<Message>> {
            override fun onError(e: Error) {
                if (e.code == Code.UNAUTHENTICATED) {
                    initChatControllerAndLogin(listener) { err ->
                        if (err != null) {
                            callback(err, null)
                        } else
                            getUpdates(callback)
                    }
                } else {
                    callback(e, null)
                }
            }
            override fun onSuccess(t: List<Message>) {
                callback(null, t)
            }
        }

        if (params.offset > 0 || params.limit > 0) {
            _serviceDialog?.getUpdates(
                createHistoryRequest(params), s)

        } else {
            _serviceDialog?.getUpdates(s)
        }
    }


    private fun getUpdates(callback: (Error?, List<Message>?) -> Unit) {
        _serviceDialog?.getUpdates(object: CallbackListener<List<Message>> {
            override fun onError(e: Error) {
                callback(e, null)
            }

            override fun onSuccess(t: List<Message>) {
                callback(null, t)
            }
        })
    }


    private fun getHistoryAndLogin(params: Params,
                                   listener: DialogListener,
                                   callback: (Error?, List<Message>?) -> Unit) {
        val s = object: CallbackListener<List<Message>> {
            override fun onError(e: Error) {
                if (e.code == Code.UNAUTHENTICATED) {
                    initChatControllerAndLogin(listener) { err ->
                        if (err != null) {
                            callback(err, null)
                        } else
                            getHistory(callback)
                    }
                } else {
                    callback(e, null)
                }
            }
            override fun onSuccess(t: List<Message>) {
                callback(null, t)
            }
        }

        if (params.offset > 0 || params.limit > 0) {
            _serviceDialog?.getHistory(
                createHistoryRequest(params), s)

        } else {
            _serviceDialog?.getHistory(s)
        }
    }


    private fun createHistoryRequest(params: Params): HistoryRequest {
        val builder = HistoryRequest.Builder()

        if(params.offset > 0) builder.offset(params.offset)
        if(params.limit > 0) builder.limit(params.limit)

        return builder.build()
    }


    private fun getHistory(callback: (Error?, List<Message>?) -> Unit) {
        _serviceDialog?.getHistory(object: CallbackListener<List<Message>> {
            override fun onError(e: Error) {
                callback(e, null)
            }

            override fun onSuccess(t: List<Message>) {
                callback(null, t)
            }
        })
    }


    private fun sendAndLogin(listener: DialogListener,
                             message: Message.options,
                             callback: (Error?, Message?) -> Unit) {
        _serviceDialog?.sendMessage(message = message, object : MessageCallbackListener {
            override fun onError(e: Error) {
                if (e.code == Code.UNAUTHENTICATED) {
                    initChatControllerAndLogin(listener) { err ->
                        if (err != null) {
                            callback(err, null)
                        } else {
                            send(message, callback)
                        }
                    }
                } else {
                    callback(e, null)
                }
            }

            override fun onSend(m: Message) {}

            override fun onSent(m: Message) {
                callback(null, m)
            }
        })
    }


    private fun send(message: Message.options,
                     callback: (Error?, Message?) -> Unit){
        _serviceDialog?.sendMessage(message = message, object: MessageCallbackListener {
            override fun onError(e: Error) {
                callback(e, null)
            }

            override fun onSend(m: Message) {}

            override fun onSent(m: Message) {
                callback(null, m)
            }
        })
    }


    private fun initChatControllerAndLogin(listener: DialogListener,
                                           callback: (Error?) -> Unit) {
        _portalClient?.getChatClient(object: CallbackListener<ChatClient> {
            override fun onError(e: Error) {
                if (e.code == Code.UNAUTHENTICATED) {
                    login { err ->
                        if (err != null) {
                            callback(err)
                            return@login
                        }

                        initChatController(listener, callback)
                    }
                } else {
                    callback(e)
                }
            }

            override fun onSuccess(t: ChatClient) {
                _chatClient = t
                findServiceDialog(listener, t, callback)
            }
        })
    }


    private fun initChatController(listener: DialogListener,
                                   callback: (Error?) -> Unit) {
        _portalClient?.getChatClient(object: CallbackListener<ChatClient> {
            override fun onError(e: Error) {
                callback(e)
            }

            override fun onSuccess(t: ChatClient) {
                _chatClient = t
                findServiceDialog(listener, t, callback)
            }
        })
    }


    private fun findServiceDialog(listener: DialogListener,
                                  t: ChatClient,
                                  callback: (Error?) -> Unit) {
        t.getServiceDialog(object : CallbackListener<Dialog> {
            override fun onError(e: Error) {
                callback(e)
            }

            override fun onSuccess(t: Dialog) {
                t.addListener(listener)
                _serviceDialog = t
                callback(null)
            }
        })
    }


    private fun createClient(token: String, address: String) {
        _portalClient = PortalClient.Builder(
            application = application,
            address = address,
            token = token
        ).build()
    }


    private fun makeCallAgan(listener: CallStateListener, callback: (Error?) -> Unit) {
        _portalClient?.getVoiceClient(object : CallbackListener<VoiceClient> {
            override fun onError(e: Error) {
                callback(e)
            }

            override fun onSuccess(t: VoiceClient) {
                t.makeCall(listener)
                callback(null)
            }
        })
    }


    private fun login(callback: (Error?) -> Unit) {
        val u = user
        if (u != null) {
            _portalClient?.userLogin(u, object : LoginListener {
                override fun onError(e: Error) {
                    callback(e)
                }

                override fun onLoginFinished(session: Session) {
                    callback(null)
                }

                override fun onLogoutFinished() {}
            })
        }
    }


    data class Params(val limit: Int, val offset: Long)
}

