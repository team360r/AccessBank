package com.accessguide.plugin.actions

import com.intellij.openapi.actionSystem.AnAction
import com.intellij.openapi.actionSystem.AnActionEvent

class PrevStepAction : AnAction() {
    override fun actionPerformed(e: AnActionEvent) {
        // Mirror of NextStepAction — panel handles prev/next via its own buttons
        // Keyboard shortcut is a bonus; the main UI is the WebView buttons
    }
}
