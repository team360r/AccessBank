package com.accessguide.plugin

import com.intellij.openapi.Disposable
import com.intellij.openapi.diagnostic.Logger
import kotlinx.coroutines.*
import org.json.JSONObject
import java.net.URI
import java.net.http.HttpClient
import java.net.http.WebSocket
import java.util.concurrent.CompletionStage
import java.util.concurrent.atomic.AtomicBoolean

typealias MessageHandler = (String) -> Unit

class RelayClient(private val port: Int = 9274) : Disposable {

    private val log = Logger.getInstance(RelayClient::class.java)
    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private val running = AtomicBoolean(false)
    private var socket: WebSocket? = null
    private val messageHandlers = mutableListOf<MessageHandler>()

    fun onMessage(handler: MessageHandler) { messageHandlers.add(handler) }

    fun start() {
        running.set(true)
        scope.launch { connectLoop() }
    }

    private suspend fun connectLoop() {
        while (running.get()) {
            try {
                connect()
            } catch (e: Exception) {
                log.warn("AccessGuide relay disconnected: ${e.message}")
            }
            if (running.get()) delay(3_000)
        }
    }

    private suspend fun connect() = withContext(Dispatchers.IO) {
        val client = HttpClient.newHttpClient()
        val listener = object : WebSocket.Listener {
            private val sb = StringBuilder()

            override fun onOpen(ws: WebSocket) {
                socket = ws
                // Identify as IDE client
                val hello = JSONObject()
                    .put("type", "event")
                    .put("source", "ide")
                    .put("action", "connected")
                    .toString()
                ws.sendText(hello, true)
                ws.request(1)
                log.info("AccessGuide relay connected on port $port")
            }

            override fun onText(ws: WebSocket, data: CharSequence, last: Boolean): CompletionStage<*>? {
                sb.append(data)
                if (last) {
                    val msg = sb.toString()
                    sb.clear()
                    messageHandlers.forEach { it(msg) }
                }
                ws.request(1)
                return null
            }

            override fun onClose(ws: WebSocket, statusCode: Int, reason: String): CompletionStage<*>? {
                socket = null
                log.info("AccessGuide relay closed: $reason")
                return null
            }

            override fun onError(ws: WebSocket, error: Throwable) {
                socket = null
                log.warn("AccessGuide relay error: ${error.message}")
            }
        }

        client.newWebSocketBuilder()
            .buildAsync(URI("ws://localhost:$port/ws"), listener)
            .join()

        // Block until disconnected (poll socket presence)
        while (socket != null && running.get()) {
            delay(500)
        }
    }

    fun send(message: String) {
        socket?.sendText(message, true) ?: log.warn("AccessGuide: tried to send but not connected")
    }

    fun sendAction(action: String, payload: JSONObject = JSONObject()) {
        val msg = JSONObject()
            .put("type", "command")
            .put("source", "ide")
            .put("action", action)
            .put("payload", payload)
            .toString()
        send(msg)
    }

    override fun dispose() {
        running.set(false)
        scope.cancel()
        socket?.sendClose(WebSocket.NORMAL_CLOSURE, "plugin disposed")
    }
}
