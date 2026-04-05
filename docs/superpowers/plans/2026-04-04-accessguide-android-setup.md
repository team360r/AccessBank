# AccessGuide Android Studio Plugin + Setup Script Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Android Studio plugin that renders the same shared HTML tutorial panel, and a single `./setup.sh` that installs everything on Mac automatically.

**Architecture:** The Android Studio plugin is a Kotlin IntelliJ Platform plugin that hosts `JBCefBrowser` (Chromium-based, bundled with Android Studio). It renders `tools/shared/tutorial_panel.html` — the exact same file used by the VS Code extension. A Kotlin `CefMessageRouter` bridges JS ↔ plugin host for message passing. A `RelayClient` (Kotlin, using `java.net.http.HttpClient`) connects to the same `ws://localhost:9274/ws` server. Device management mirrors the VS Code implementation.

**Tech Stack:** Kotlin, IntelliJ Platform Gradle Plugin, JBCefBrowser (CEF), `java.net.http.HttpClient` WebSocket API, Bash (setup.sh).

**Deliverable:** After running `./setup.sh` on a clean Mac with VS Code and/or Android Studio installed and a physical phone connected, the tutorial panel appears in the IDE, controls the phone, and the learner can start Chapter 0 without any manual steps.

**Depends on:** Sub-Plan 1 (core infrastructure) and Sub-Plan 2 (shared HTML panel + `tutorial_content.json`).

---

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `tools/android-studio-plugin/build.gradle.kts` | Create | IntelliJ Platform Gradle Plugin config, target Android Studio Ladybug+ |
| `tools/android-studio-plugin/gradle/wrapper/gradle-wrapper.properties` | Create | Gradle wrapper pointing to 8.x |
| `tools/android-studio-plugin/settings.gradle.kts` | Create | Project name declaration |
| `tools/android-studio-plugin/src/main/resources/META-INF/plugin.xml` | Create | Plugin descriptor: ID, name, dependencies, extensions |
| `tools/android-studio-plugin/src/main/resources/tutorial_panel.html` | Copy | Bundled from `tools/shared/tutorial_panel.html` at build time |
| `tools/android-studio-plugin/src/main/resources/tutorial_content.json` | Copy | Bundled from `tools/shared/tutorial_content.json` at build time |
| `tools/android-studio-plugin/src/main/kotlin/com/accessguide/plugin/TutorialToolWindowFactory.kt` | Create | `ToolWindowFactory`: creates `JBCefBrowser`, sets up CEF message router |
| `tools/android-studio-plugin/src/main/kotlin/com/accessguide/plugin/RelayClient.kt` | Create | Kotlin WebSocket client to `ws://localhost:9274/ws` |
| `tools/android-studio-plugin/src/main/kotlin/com/accessguide/plugin/DeviceManager.kt` | Create | Poll `flutter devices`, auto-launch `flutter run`, `adb reverse` |
| `tools/android-studio-plugin/src/main/kotlin/com/accessguide/plugin/ServerManager.kt` | Create | Start/stop Dart tutorial server subprocess |
| `tools/android-studio-plugin/src/main/kotlin/com/accessguide/plugin/TutorialStartupActivity.kt` | Create | `StartupActivity`: auto-activates when AccessBank project opens |
| `setup.sh` | Create | Mac-only installer: detects IDEs, installs extensions, validates device |

---

## Task 20: Android Studio plugin — project scaffolding

**Files:**
- Create: `tools/android-studio-plugin/build.gradle.kts`
- Create: `tools/android-studio-plugin/gradle/wrapper/gradle-wrapper.properties`
- Create: `tools/android-studio-plugin/settings.gradle.kts`
- Create: `tools/android-studio-plugin/src/main/resources/META-INF/plugin.xml`

- [ ] **Step 1: Create the Gradle build file**

Create `tools/android-studio-plugin/build.gradle.kts`:

```kotlin
plugins {
    id("org.jetbrains.intellij.platform") version "2.3.0"
    kotlin("jvm") version "1.9.23"
}

group = "com.accessguide"
version = "1.0.0"

repositories {
    mavenCentral()
    intellijPlatform {
        defaultRepositories()
    }
}

dependencies {
    intellijPlatform {
        // Target Android Studio Ladybug (2024.2.1) or newer
        androidStudio("2024.2.1.11")
        bundledPlugins("com.intellij.java")
        instrumentationTools()
    }
}

intellijPlatform {
    pluginConfiguration {
        name = "AccessGuide Tutorial"
        version = project.version.toString()
        ideaVersion {
            sinceBuild = "242"
            untilBuild = provider { null }
        }
    }
    publishing {
        token = System.getenv("INTELLIJ_PUBLISH_TOKEN") ?: ""
    }
    signing {
        // Left empty — private distribution, no signing required
    }
}

tasks {
    // Copy shared resources into plugin bundle at build time
    processResources {
        from("../shared/tutorial_panel.html")
        from("../shared/tutorial_content.json")
    }

    compileKotlin {
        kotlinOptions.jvmTarget = "17"
    }
    compileTestKotlin {
        kotlinOptions.jvmTarget = "17"
    }
}
```

- [ ] **Step 2: Create Gradle wrapper properties**

Create `tools/android-studio-plugin/gradle/wrapper/gradle-wrapper.properties`:

```properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.7-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
```

- [ ] **Step 3: Create settings.gradle.kts**

Create `tools/android-studio-plugin/settings.gradle.kts`:

```kotlin
rootProject.name = "accessguide-plugin"
```

- [ ] **Step 4: Create the plugin descriptor**

Create `tools/android-studio-plugin/src/main/resources/META-INF/plugin.xml`:

```xml
<idea-plugin>
  <id>com.accessguide.plugin</id>
  <name>AccessGuide Tutorial</name>
  <version>1.0.0</version>
  <vendor>AccessGuide</vendor>

  <description>
    Interactive accessibility tutorial panel for the AccessBank Flutter project.
    Controls the tethered phone and displays chapter content alongside the code editor.
  </description>

  <depends>com.intellij.modules.platform</depends>
  <depends>com.intellij.modules.java</depends>

  <extensions defaultExtensionNs="com.intellij">
    <toolWindow
        id="AccessGuide"
        displayName="Tutorial"
        anchor="right"
        factoryClass="com.accessguide.plugin.TutorialToolWindowFactory"
        icon="/icons/accessguide.svg"
    />
    <postStartupActivity
        implementation="com.accessguide.plugin.TutorialStartupActivity"
    />
  </extensions>

  <actions>
    <action
        id="AccessGuide.NextStep"
        class="com.accessguide.plugin.actions.NextStepAction"
        text="Next Tutorial Step"
        description="Advance to the next tutorial step"
    />
    <action
        id="AccessGuide.PrevStep"
        class="com.accessguide.plugin.actions.PrevStepAction"
        text="Previous Tutorial Step"
        description="Go back to the previous tutorial step"
    />
  </actions>
</idea-plugin>
```

- [ ] **Step 5: Verify scaffold compiles**

```bash
cd tools/android-studio-plugin && ./gradlew compileKotlin
```

Expected: BUILD SUCCESSFUL. The plugin descriptor is valid.

---

## Task 21: Android Studio plugin — RelayClient (Kotlin WebSocket)

**Files:**
- Create: `tools/android-studio-plugin/src/main/kotlin/com/accessguide/plugin/RelayClient.kt`

- [ ] **Step 1: Create RelayClient using java.net.http WebSocket**

Create `tools/android-studio-plugin/src/main/kotlin/com/accessguide/plugin/RelayClient.kt`:

```kotlin
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
```

- [ ] **Step 2: Add org.json dependency to build.gradle.kts**

Edit `tools/android-studio-plugin/build.gradle.kts` — add to the `dependencies` block:

```kotlin
implementation("org.json:json:20240303")
```

- [ ] **Step 3: Verify compilation**

```bash
cd tools/android-studio-plugin && ./gradlew compileKotlin
```

Expected: BUILD SUCCESSFUL.

---

## Task 22: Android Studio plugin — ServerManager

**Files:**
- Create: `tools/android-studio-plugin/src/main/kotlin/com/accessguide/plugin/ServerManager.kt`

- [ ] **Step 1: Create ServerManager**

Create `tools/android-studio-plugin/src/main/kotlin/com/accessguide/plugin/ServerManager.kt`:

```kotlin
package com.accessguide.plugin

import com.intellij.openapi.Disposable
import com.intellij.openapi.diagnostic.Logger
import com.intellij.openapi.project.Project
import java.io.File

class ServerManager(private val project: Project) : Disposable {

    private val log = Logger.getInstance(ServerManager::class.java)
    private var process: Process? = null

    /** Start the Dart tutorial server if not already running. */
    fun startIfNeeded() {
        if (process?.isAlive == true) return

        val projectRoot = project.basePath ?: return
        val serverDir = File(projectRoot, "tools/tutorial_server")
        if (!serverDir.exists()) {
            log.warn("AccessGuide: tutorial server directory not found at $serverDir")
            return
        }

        log.info("AccessGuide: starting tutorial server")
        process = ProcessBuilder("dart", "run", "bin/server.dart")
            .directory(serverDir)
            .inheritIO()
            .start()
    }

    override fun dispose() {
        process?.destroyForcibly()
        process = null
    }
}
```

---

## Task 23: Android Studio plugin — DeviceManager

**Files:**
- Create: `tools/android-studio-plugin/src/main/kotlin/com/accessguide/plugin/DeviceManager.kt`

- [ ] **Step 1: Create DeviceManager mirroring VS Code implementation**

Create `tools/android-studio-plugin/src/main/kotlin/com/accessguide/plugin/DeviceManager.kt`:

```kotlin
package com.accessguide.plugin

import com.intellij.openapi.Disposable
import com.intellij.openapi.diagnostic.Logger
import com.intellij.openapi.project.Project
import kotlinx.coroutines.*
import org.json.JSONArray
import org.json.JSONObject

data class DetectedDevice(val id: String, val platform: String, val name: String)

class DeviceManager(
    private val project: Project,
    private val onDeviceConnected: (DetectedDevice) -> Unit,
    private val onNoDevice: () -> Unit,
) : Disposable {

    private val log = Logger.getInstance(DeviceManager::class.java)
    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private var flutterProcess: Process? = null
    private var lastDeviceId: String? = null

    fun start() {
        scope.launch { pollLoop() }
    }

    private suspend fun pollLoop() {
        while (isActive) {
            try {
                pollDevices()
            } catch (e: Exception) {
                log.warn("AccessGuide device poll error: ${e.message}")
            }
            delay(5_000)
        }
    }

    private fun pollDevices() {
        val output = ProcessBuilder("flutter", "devices", "--machine")
            .directory(java.io.File(project.basePath ?: return))
            .start()
            .inputStream.bufferedReader().readText()

        val devices = JSONArray(output)
        val physical = (0 until devices.length())
            .map { devices.getJSONObject(it) }
            .filter { !it.optBoolean("isEmulator") && it.optString("id") != "flutter-tester" }

        if (physical.isEmpty()) {
            if (lastDeviceId != null) {
                lastDeviceId = null
                flutterProcess?.destroyForcibly()
                flutterProcess = null
            }
            onNoDevice()
            return
        }

        val device = physical.first()
        val deviceId = device.getString("id")
        val platform = device.optString("targetPlatform", "unknown")
        val name = device.optString("name", deviceId)

        if (deviceId == lastDeviceId && flutterProcess?.isAlive == true) return

        lastDeviceId = deviceId
        launchFlutter(DetectedDevice(deviceId, platform, name))
    }

    private fun launchFlutter(device: DetectedDevice) {
        flutterProcess?.destroyForcibly()

        val projectRoot = project.basePath ?: return
        val args = mutableListOf("flutter", "run", "--device-id", device.id)

        when {
            device.platform.contains("android") -> {
                // Port-forward so app's localhost:9274 → Mac's localhost:9274
                ProcessBuilder("adb", "-s", device.id, "reverse", "tcp:9274", "tcp:9274")
                    .directory(java.io.File(projectRoot))
                    .start()
                args += listOf("--dart-define", "TUTORIAL_HOST=localhost")
            }
            device.platform.contains("ios") -> {
                // iOS on USB can reach the Mac via its LAN IP
                val ip = discoverMacIp()
                args += listOf("--dart-define", "TUTORIAL_HOST=$ip")
            }
        }
        args += listOf("--dart-define", "TUTORIAL_PORT=9274")

        log.info("AccessGuide: launching flutter run on ${device.name}")
        flutterProcess = ProcessBuilder(args)
            .directory(java.io.File(projectRoot))
            .inheritIO()
            .start()

        onDeviceConnected(device)
    }

    private fun discoverMacIp(): String {
        for (iface in listOf("en0", "en1")) {
            try {
                val output = ProcessBuilder("ipconfig", "getifaddr", iface)
                    .start()
                    .inputStream.bufferedReader().readText().trim()
                if (output.matches(Regex("\\d+\\.\\d+\\.\\d+\\.\\d+"))) return output
            } catch (_: Exception) {}
        }
        return "localhost"
    }

    override fun dispose() {
        scope.cancel()
        flutterProcess?.destroyForcibly()
    }
}
```

---

## Task 24: Android Studio plugin — TutorialToolWindowFactory (JBCefBrowser)

**Files:**
- Create: `tools/android-studio-plugin/src/main/kotlin/com/accessguide/plugin/TutorialToolWindowFactory.kt`

- [ ] **Step 1: Create the ToolWindowFactory with JBCefBrowser**

Create `tools/android-studio-plugin/src/main/kotlin/com/accessguide/plugin/TutorialToolWindowFactory.kt`:

```kotlin
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
```

- [ ] **Step 2: Verify the factory compiles**

```bash
cd tools/android-studio-plugin && ./gradlew compileKotlin
```

Expected: BUILD SUCCESSFUL (no unresolved references).

---

## Task 25: Android Studio plugin — TutorialStartupActivity + actions

**Files:**
- Create: `tools/android-studio-plugin/src/main/kotlin/com/accessguide/plugin/TutorialStartupActivity.kt`
- Create: `tools/android-studio-plugin/src/main/kotlin/com/accessguide/plugin/actions/NextStepAction.kt`
- Create: `tools/android-studio-plugin/src/main/kotlin/com/accessguide/plugin/actions/PrevStepAction.kt`

- [ ] **Step 1: Create TutorialStartupActivity**

Create `tools/android-studio-plugin/src/main/kotlin/com/accessguide/plugin/TutorialStartupActivity.kt`:

```kotlin
package com.accessguide.plugin

import com.intellij.openapi.diagnostic.Logger
import com.intellij.openapi.project.Project
import com.intellij.openapi.startup.ProjectActivity
import com.intellij.openapi.wm.ToolWindowManager

class TutorialStartupActivity : ProjectActivity {

    private val log = Logger.getInstance(TutorialStartupActivity::class.java)

    override suspend fun execute(project: Project) {
        // Only auto-open for AccessBank projects (has pubspec.yaml)
        val isAccessBank = project.basePath?.let {
            java.io.File(it, "pubspec.yaml").exists()
        } == true

        if (!isAccessBank) return

        log.info("AccessGuide: AccessBank project detected, opening tutorial panel")
        val toolWindowManager = ToolWindowManager.getInstance(project)
        val toolWindow = toolWindowManager.getToolWindow("AccessGuide") ?: return
        if (!toolWindow.isVisible) {
            toolWindow.show()
        }
    }
}
```

- [ ] **Step 2: Create keyboard shortcut actions**

Create `tools/android-studio-plugin/src/main/kotlin/com/accessguide/plugin/actions/NextStepAction.kt`:

```kotlin
package com.accessguide.plugin.actions

import com.intellij.openapi.actionSystem.AnAction
import com.intellij.openapi.actionSystem.AnActionEvent

class NextStepAction : AnAction() {
    override fun actionPerformed(e: AnActionEvent) {
        // Relay client is owned by the tool window — actions post via JS injection
        // The simplest approach: fire a JS event that the panel handles
        val project = e.project ?: return
        val twm = com.intellij.openapi.wm.ToolWindowManager.getInstance(project)
        val tw = twm.getToolWindow("AccessGuide") ?: return
        // Tool window content is a JBCefBrowser; we trigger via postMessage JS
        tw.contentManager.selectedContent?.component?.let { comp ->
            // JBCefBrowser is wrapped in the component hierarchy — find it via userData
            // Simpler: store RelayClient as project service and call sendAction directly
            // For now, the panel's prev/next buttons handle this via WebView JS
        }
    }
}
```

Create `tools/android-studio-plugin/src/main/kotlin/com/accessguide/plugin/actions/PrevStepAction.kt`:

```kotlin
package com.accessguide.plugin.actions

import com.intellij.openapi.actionSystem.AnAction
import com.intellij.openapi.actionSystem.AnActionEvent

class PrevStepAction : AnAction() {
    override fun actionPerformed(e: AnActionEvent) {
        // Mirror of NextStepAction — panel handles prev/next via its own buttons
        // Keyboard shortcut is a bonus; the main UI is the WebView buttons
    }
}
```

**Note:** The prev/next keyboard actions are stubs for now. The panel's built-in "Prev" and "Next" buttons are the primary navigation. Wiring these actions to the relay client requires storing `RelayClient` as a project-level service — a post-MVP improvement.

- [ ] **Step 3: Build the plugin**

```bash
cd tools/android-studio-plugin && ./gradlew buildPlugin
```

Expected: `build/distributions/accessguide-plugin-1.0.0.zip` created. Size should be ~5–15 MB (JBCef JARs are bundled by Android Studio, not the plugin).

---

## Task 26: Android Studio plugin — smoke test

**Files:** None (verification only)

- [ ] **Step 1: Install the plugin in Android Studio for manual testing**

```bash
# Find the Android Studio plugins directory
AS_PLUGINS="$HOME/Library/Application Support/Google/AndroidStudio*/plugins"
mkdir -p $AS_PLUGINS
cp tools/android-studio-plugin/build/distributions/accessguide-plugin-1.0.0.zip "$AS_PLUGINS/"
```

Restart Android Studio → Preferences → Plugins → Install Plugin from Disk → select the zip.

- [ ] **Step 2: Open the AccessBank project in Android Studio**

Expected:
- "Tutorial" tool window appears in the right sidebar automatically
- Tutorial panel loads with Chapter 0 content
- Connection status shows "Connecting..." (server not yet started)

- [ ] **Step 3: Start the tutorial server, connect a physical device**

```bash
dart run tools/tutorial_server/bin/server.dart
```

Expected:
- Plugin connects to relay (connection indicator goes green)
- Physical phone detected (Android Studio auto-launches `flutter run`)
- Phone displays AccessBank with status bar "Ch 0 · Step 1/6"
- Clicking "Next" in panel advances step on both panel and phone

---

## Task 27: Setup script — `setup.sh`

**Files:**
- Create: `setup.sh`

- [ ] **Step 1: Create the setup script**

Create `setup.sh` at the project root:

```bash
#!/usr/bin/env bash
set -euo pipefail

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

info()    { echo -e "${BLUE}▶${NC} $*"; }
success() { echo -e "${GREEN}✓${NC} $*"; }
warn()    { echo -e "${YELLOW}⚠${NC} $*"; }
error()   { echo -e "${RED}✗${NC} $*"; exit 1; }

echo ""
echo "  AccessGuide Setup"
echo "  ─────────────────"
echo ""

# ── 1. Platform check ───────────────────────────────────────────────────────
if [[ "$(uname)" != "Darwin" ]]; then
  error "This setup script only runs on macOS."
fi
success "Running on macOS"

# ── 2. Dependency checks ─────────────────────────────────────────────────────
info "Checking required tools..."

command -v flutter >/dev/null 2>&1 || error "Flutter SDK not found. Install from https://flutter.dev"
success "Flutter: $(flutter --version --machine 2>/dev/null | python3 -c 'import sys,json; d=json.load(sys.stdin); print(d.get(\"frameworkVersion\",\"unknown\"))' 2>/dev/null || echo 'installed')"

command -v dart >/dev/null 2>&1 || error "Dart SDK not found (should come with Flutter)."
success "Dart: $(dart --version 2>&1 | head -1)"

command -v git >/dev/null 2>&1 || error "Git not found."
success "Git: $(git --version)"

# ── 3. Flutter pub get ────────────────────────────────────────────────────────
info "Installing Flutter dependencies..."
flutter pub get
success "Flutter dependencies installed"

# ── 4. Tutorial server dependencies ──────────────────────────────────────────
info "Installing tutorial server dependencies..."
(cd tools/tutorial_server && dart pub get)
success "Tutorial server dependencies installed"

# ── 5. Generate tutorial content JSON ────────────────────────────────────────
info "Generating tutorial content..."
dart tools/generate_content.dart
success "Tutorial content generated → tools/shared/tutorial_content.json"

# ── 6. VS Code extension ──────────────────────────────────────────────────────
VSCODE_APP="/Applications/Visual Studio Code.app"
if [[ -d "$VSCODE_APP" ]]; then
  info "Installing VS Code extension..."

  # Find the pre-built .vsix
  VSIX=$(ls tools/vscode-extension/*.vsix 2>/dev/null | head -1)
  if [[ -z "$VSIX" ]]; then
    warn "No pre-built .vsix found. Building from source..."
    if command -v npm >/dev/null 2>&1; then
      (cd tools/vscode-extension && npm install && npm run compile && npx vsce package --no-dependencies 2>/dev/null || npx @vscode/vsce package --no-dependencies)
      VSIX=$(ls tools/vscode-extension/*.vsix 2>/dev/null | head -1)
    else
      warn "npm not found — skipping VS Code extension install. Install Node.js and re-run."
    fi
  fi

  if [[ -n "$VSIX" ]]; then
    code --install-extension "$VSIX" --force
    success "VS Code extension installed: $VSIX"
  fi
else
  warn "VS Code not found at $VSCODE_APP — skipping VS Code extension."
fi

# ── 7. Android Studio plugin ──────────────────────────────────────────────────
AS_PLUGIN_ZIP=$(ls tools/android-studio-plugin/build/distributions/*.zip 2>/dev/null | head -1)
AS_PLUGINS_DIR=$(ls -d "$HOME/Library/Application Support/Google/AndroidStudio"*/plugins 2>/dev/null | head -1)

if [[ -d "/Applications/Android Studio.app" ]]; then
  info "Installing Android Studio plugin..."

  if [[ -z "$AS_PLUGIN_ZIP" ]]; then
    warn "No pre-built plugin .zip found in tools/android-studio-plugin/build/distributions/"
    warn "Build it with: cd tools/android-studio-plugin && ./gradlew buildPlugin"
    warn "Then re-run ./setup.sh"
  elif [[ -z "$AS_PLUGINS_DIR" ]]; then
    warn "Android Studio plugins directory not found — you may need to open Android Studio once first."
    warn "Plugin zip is at: $AS_PLUGIN_ZIP"
    warn "Install manually: Preferences → Plugins → ⚙ → Install Plugin from Disk"
  else
    cp "$AS_PLUGIN_ZIP" "$AS_PLUGINS_DIR/"
    success "Android Studio plugin installed to $AS_PLUGINS_DIR"
    warn "Restart Android Studio to activate the plugin."
  fi
else
  warn "Android Studio not found — skipping Android Studio plugin."
fi

# ── 8. Create .tutorial directory ─────────────────────────────────────────────
mkdir -p .tutorial
success ".tutorial/ state directory created"

# ── 9. Physical device check ──────────────────────────────────────────────────
info "Checking for connected physical devices..."

DEVICES_JSON=$(flutter devices --machine 2>/dev/null || echo "[]")
PHYSICAL_COUNT=$(echo "$DEVICES_JSON" | python3 -c "
import sys, json
devices = json.load(sys.stdin)
physical = [d for d in devices if not d.get('isEmulator', True) and d.get('id') != 'flutter-tester']
print(len(physical))
" 2>/dev/null || echo "0")

if [[ "$PHYSICAL_COUNT" -eq 0 ]]; then
  echo ""
  echo -e "${YELLOW}  ┌──────────────────────────────────────────────────────────┐${NC}"
  echo -e "${YELLOW}  │  No physical device detected.                           │${NC}"
  echo -e "${YELLOW}  │                                                          │${NC}"
  echo -e "${YELLOW}  │  Connect a physical iPhone or Android phone via USB,     │${NC}"
  echo -e "${YELLOW}  │  then open your IDE — the tutorial panel will launch     │${NC}"
  echo -e "${YELLOW}  │  flutter run automatically.                              │${NC}"
  echo -e "${YELLOW}  └──────────────────────────────────────────────────────────┘${NC}"
  echo ""
else
  success "$PHYSICAL_COUNT physical device(s) connected"
  flutter devices --machine 2>/dev/null | python3 -c "
import sys, json
devices = json.load(sys.stdin)
for d in devices:
    if not d.get('isEmulator', True) and d.get('id') != 'flutter-tester':
        print(f\"  • {d.get('name', d['id'])} ({d.get('targetPlatform', 'unknown')})\")
  "
fi

# ── 10. Success summary ───────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}  ┌──────────────────────────────────────────────────────────┐${NC}"
echo -e "${GREEN}  │  AccessGuide setup complete!                             │${NC}"
echo -e "${GREEN}  │                                                          │${NC}"
echo -e "${GREEN}  │  Next steps:                                             │${NC}"
echo -e "${GREEN}  │  1. Open this project in VS Code or Android Studio       │${NC}"
echo -e "${GREEN}  │  2. Connect a physical iPhone or Android phone via USB   │${NC}"
echo -e "${GREEN}  │  3. The Tutorial panel will appear automatically         │${NC}"
echo -e "${GREEN}  │                                                          │${NC}"
echo -e "${GREEN}  │  The tutorial server starts automatically when you       │${NC}"
echo -e "${GREEN}  │  open the Tutorial panel in your IDE.                    │${NC}"
echo -e "${GREEN}  └──────────────────────────────────────────────────────────┘${NC}"
echo ""
```

- [ ] **Step 2: Make setup.sh executable**

```bash
chmod +x setup.sh
```

- [ ] **Step 3: Run setup.sh on a clean state to verify**

```bash
./setup.sh
```

Expected output (no physical device connected):
```
  AccessGuide Setup
  ─────────────────

✓ Running on macOS
▶ Checking required tools...
✓ Flutter: 3.x.x
✓ Dart: Dart SDK version 3.x.x
✓ Git: git version 2.x.x
▶ Installing Flutter dependencies...
✓ Flutter dependencies installed
▶ Installing tutorial server dependencies...
✓ Tutorial server dependencies installed
▶ Generating tutorial content...
✓ Tutorial content generated → tools/shared/tutorial_content.json
▶ Installing VS Code extension...
✓ VS Code extension installed: tools/vscode-extension/accessguide-1.0.0.vsix
▶ Checking for connected physical devices...

  ┌──────────────────────────────────────────────────────────┐
  │  No physical device detected.                           │
  ...

  ┌──────────────────────────────────────────────────────────┐
  │  AccessGuide setup complete!                             │
```

Exit code: 0 (the no-device state is a warning, not a fatal error).

---

## Task 28: Integration verification (end-to-end)

**Files:** None (verification only)

This task verifies that all three sub-plans connect correctly.

- [ ] **Step 1: Verify full pipeline from a clean state**

```bash
# 1. Generate content
dart tools/generate_content.dart
# → tools/shared/tutorial_content.json must exist and be valid JSON

# 2. Start the server
dart run tools/tutorial_server/bin/server.dart &
SERVER_PID=$!
sleep 2

# 3. Test relay with two websocat clients (install: brew install websocat)
# Terminal A (IDE):
echo '{"type":"event","source":"ide","action":"connected"}' | websocat ws://localhost:9274/ws &

# Terminal B (app):
echo '{"type":"event","source":"app","action":"connected","payload":{"device":"Test"}}' | websocat ws://localhost:9274/ws &

# 4. Send a next_step command
echo '{"type":"command","source":"ide","action":"next_step"}' | websocat ws://localhost:9274/ws

# 5. Observe that both clients receive the tutorial_state broadcast

kill $SERVER_PID
```

- [ ] **Step 2: Verify end-to-end with VS Code + iPhone**

Manual checklist:
- [ ] `./setup.sh` completes with exit code 0
- [ ] Open project in VS Code — Tutorial panel appears on the right
- [ ] Chapter 0 content loads (title, step text, code diff)
- [ ] Connect an iPhone via USB — phone launches AccessBank automatically
- [ ] Phone status bar shows "Ch 0 · Step 1/6"
- [ ] Click "Next" — panel advances to step 2, phone status bar updates
- [ ] Toggle "Before/After" — phone UI switches accessible mode
- [ ] Edit `lib/screens/login_screen.dart` to add the expected `Semantics` wrapper — green checkmark appears in panel
- [ ] Undo the edit — green checkmark disappears
- [ ] Disconnect phone — panel shows "Disconnected" state
- [ ] Reconnect phone — panel shows connected state and resumes

- [ ] **Step 3: Verify progress persistence**

1. Advance to Chapter 2, Step 3
2. Stop the tutorial server
3. Restart the server: `dart run tools/tutorial_server/bin/server.dart`
4. Re-open VS Code panel

Expected: Panel resumes at Chapter 2, Step 3.

---

## Verification Summary

| Check | Command | Expected |
|-------|---------|----------|
| Plugin builds | `cd tools/android-studio-plugin && ./gradlew buildPlugin` | `build/distributions/*.zip` exists |
| Plugin installs | Preferences → Plugins → Install from disk | No errors |
| Setup script runs | `./setup.sh` | Exit 0, summary printed |
| Content generated | `ls tools/shared/tutorial_content.json` | File exists, valid JSON |
| Plugin opens panel | Open project in Android Studio | Tutorial tool window appears |
| Phone launches | Connect physical device | `flutter run` starts automatically |
| Server starts | Server log | `AccessGuide server listening on :9274` |
| Panel controls phone | Click Next | Both panel and phone advance |

---

## Notes

- **JBCef availability:** `JBCefBrowser` is bundled with Android Studio since 2020.3. Minimum target is Ladybug (2024.2.1, build 242). No separate CEF download needed.
- **Plugin signing:** Not required for private distribution via `.zip`. The `./gradlew buildPlugin` output installs directly.
- **Android Studio restart required:** The plugin copy step in `setup.sh` requires a manual restart — there is no CLI equivalent to VS Code's `code --install-extension` for Android Studio.
- **`ProjectActivity` vs `StartupActivity`:** The newer `ProjectActivity` (coroutine-based) is used instead of the deprecated `StartupActivity` interface. Requires IntelliJ Platform 2023.1+.
- **Gradle version:** IntelliJ Platform Gradle Plugin 2.x requires Gradle 8.x. The wrapper properties pin Gradle 8.7.
