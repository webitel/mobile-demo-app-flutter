package com.webitel.flutter_demo_app

import android.app.Application
import android.util.Log
import com.webitel.mobile_sdk.domain.Call
import com.webitel.mobile_sdk.domain.CallStateListener
import com.webitel.mobile_sdk.domain.CallbackListener
import com.webitel.mobile_sdk.domain.Code
import com.webitel.mobile_sdk.domain.Error
import com.webitel.mobile_sdk.domain.LoginListener
import com.webitel.mobile_sdk.domain.PortalClient
import com.webitel.mobile_sdk.domain.Session
import com.webitel.mobile_sdk.domain.User
import com.webitel.mobile_sdk.domain.VoiceClient

internal class PortalCustomerService(private val application: Application) {
    private var user: User? = null
    private var PORTAL_CLIENT = ""
    private var ADDRESS = ""

    private var _portalClient: PortalClient? = null


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
}

