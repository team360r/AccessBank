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
    implementation("org.json:json:20240303")
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
