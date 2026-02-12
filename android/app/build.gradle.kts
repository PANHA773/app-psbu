plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.university_news_app"

    // ✅ REQUIRED by plugins
    compileSdk = 36

    defaultConfig {
        applicationId = "com.example.university_news_app"

        // ✅ SAFE & correct
        minSdk = flutter.minSdkVersion
        targetSdk = 36

        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Optional (safe to keep)
    lint {
        checkReleaseBuilds = false
        abortOnError = false
    }
}

flutter {
    source = "../.."
}
