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
        while (scope.isActive) {
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
