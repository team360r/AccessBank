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
