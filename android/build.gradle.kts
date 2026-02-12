import org.gradle.api.file.Directory
import org.gradle.api.tasks.Delete

buildscript {
    val kotlinVersion = "1.9.22"

    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // ✅ Use stable AGP (lint-safe)
        classpath("com.android.tools.build:gradle:8.0.2")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

// ===================== All projects =====================
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ===================== Custom build directory =====================
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()

rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    project.layout.buildDirectory.set(newBuildDir.dir(project.name))
}

// Ensure app is evaluated first
subprojects {
    project.evaluationDependsOn(":app")
}

// ❌ REMOVE Kotlin toolchain forcing for plugins
// (AGP already configures this safely)

// ===================== Clean task =====================
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
