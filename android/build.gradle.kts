import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

buildscript {
    val kotlinVersion = "1.9.22"

    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.1.0")
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
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

// Make sure app is evaluated before subprojects
subprojects {
    project.evaluationDependsOn(":app")
}

// ===================== Clean task =====================
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
