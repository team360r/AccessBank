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
