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

// ✅ Harmonize Java version to 17 across all projects and tasks
subprojects {
    val syncJavaVersion = Action<Project> {
        tasks.withType<JavaCompile>().configureEach {
            sourceCompatibility = "17"
            targetCompatibility = "17"
            options.compilerArgs.addAll(listOf("-Xlint:-deprecation", "-Xlint:-unchecked"))
        }
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            kotlinOptions {
                jvmTarget = "17"
            }
        }
        // Force it in the android extension if present
        plugins.withType<com.android.build.gradle.BasePlugin> {
            val android = project.extensions.getByType(com.android.build.gradle.BaseExtension::class.java)
            android.compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
    }

    if (project.state.executed) {
        syncJavaVersion.execute(project)
    } else {
        project.afterEvaluate(syncJavaVersion)
    }
}

// ❌ REMOVE Kotlin toolchain forcing for plugins
// (AGP already configures this safely)

// ===================== Clean task =====================
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
