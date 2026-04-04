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
