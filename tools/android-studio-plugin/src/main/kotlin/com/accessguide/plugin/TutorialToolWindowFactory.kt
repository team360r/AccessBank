package com.accessguide.plugin

import com.intellij.openapi.diagnostic.Logger
import com.intellij.openapi.project.Project
import com.intellij.openapi.wm.ToolWindow
import com.intellij.openapi.wm.ToolWindowFactory
import com.intellij.ui.content.ContentFactory
import com.intellij.ui.jcef.JBCefBrowser
import com.intellij.ui.jcef.JBCefBrowserBase
import com.intellij.ui.jcef.JBCefJSQuery
import org.cef.browser.CefBrowser
import org.cef.browser.CefFrame
import org.cef.handler.CefLoadHandlerAdapter
import org.json.JSONObject
import java.io.File
import java.nio.file.Files
import javax.swing.SwingUtilities

class TutorialToolWindowFactory : ToolWindowFactory {

    private val log = Logger.getInstance(TutorialToolWindowFactory::class.java)

    override fun createToolWindowContent(project: Project, toolWindow: ToolWindow) {
        val browser = JBCefBrowser()
        val relay = RelayClient()
        val serverManager = ServerManager(project)
        val deviceManager = DeviceManager(
            project,
            onDeviceConnected = { device ->
                log.info("AccessGuide: device connected ${device.name}")
                relay.sendAction("device_connected", JSONObject().put("name", device.name))
            },
            onNoDevice = {
                postToWebView(browser, """{"type":"state","action":"no_device"}""")
            }
        )

        // JS → Kotlin bridge (plugin side receives from WebView)
        val jsQuery = JBCefJSQuery.create(browser as JBCefBrowserBase)
        jsQuery.addHandler { message ->
            handleWebViewMessage(message, relay)
            null
        }

        // Inject the bridge function after every page load
        browser.jbCefClient.addLoadHandler(object : CefLoadHandlerAdapter() {
            override fun onLoadEnd(b: CefBrowser?, frame: CefFrame?, httpStatusCode: Int) {
                if (frame?.isMain == true) {
                    // Inject window.__accessguidePost so JS can call back to Kotlin
                    val injection = """
                        window.__accessguidePost = function(msg) {
                            ${jsQuery.inject("msg")}
                        };
                        // Notify the page that the host bridge is ready
                        if (window.__accessguideReady) window.__accessguideReady();
                    """.trimIndent()
                    b?.executeJavaScript(injection, b.url, 0)
                }
            }
        }, browser.cefBrowser)

        // Kotlin → JS bridge (relay messages forwarded to WebView)
        relay.onMessage { message ->
            postToWebView(browser, message)
        }

        // Load the HTML panel
        val htmlUrl = extractHtmlToTemp()
        browser.loadURL(htmlUrl)

        // Wire up content
        val content = ContentFactory.getInstance()
            .createContent(browser.component, "Tutorial", false)
        toolWindow.contentManager.addContent(content)

        // Start services
        serverManager.startIfNeeded()
        relay.start()
        deviceManager.start()

        // Cleanup on dispose
        toolWindow.contentManager.addContentManagerListener(object :
            com.intellij.ui.content.ContentManagerListener {
            override fun contentRemoved(event: com.intellij.ui.content.ContentManagerEvent) {
                relay.dispose()
                deviceManager.dispose()
                serverManager.dispose()
            }
        })
    }

    private fun handleWebViewMessage(message: String, relay: RelayClient) {
        val json = runCatching { JSONObject(message) }.getOrNull() ?: return
        val action = json.optString("action")

        when (action) {
            "ready" -> {
                // WebView is loaded — fetch and push content
                relay.sendAction("request_state")
            }
            "open_url" -> {
                val url = json.optJSONObject("payload")?.optString("url") ?: return
                com.intellij.ide.BrowserUtil.browse(url)
            }
            else -> relay.send(message) // Forward everything else to server
        }
    }

    private fun postToWebView(browser: JBCefBrowser, message: String) {
        val escaped = message.replace("\\", "\\\\").replace("'", "\\'")
        SwingUtilities.invokeLater {
            browser.cefBrowser.executeJavaScript(
                "if(window.__accessguideReceive) window.__accessguideReceive('$escaped');",
                browser.cefBrowser.url, 0
            )
        }
    }

    /** Extract the bundled tutorial_panel.html to a temp file and return file:// URL. */
    private fun extractHtmlToTemp(): String {
        val html = javaClass.classLoader.getResourceAsStream("tutorial_panel.html")
            ?.bufferedReader()?.readText()
            ?: error("tutorial_panel.html not found in plugin resources")

        // Also extract tutorial_content.json alongside it
        val content = javaClass.classLoader.getResourceAsStream("tutorial_content.json")
            ?.bufferedReader()?.readText() ?: "{}"

        val tempDir = Files.createTempDirectory("accessguide").toFile()
        tempDir.deleteOnExit()

        File(tempDir, "tutorial_panel.html").writeText(html)
        File(tempDir, "tutorial_content.json").writeText(content)

        return "file://${tempDir.absolutePath}/tutorial_panel.html"
    }
}
