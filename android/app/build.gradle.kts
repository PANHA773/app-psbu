plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.university_news_app"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.example.university_news_app"
        minSdk = flutter.minSdkVersion         // ⚡ replace flutter.minSdkVersion with actual number
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
            isShrinkResources = false   // ✅ fixed
            signingConfig = signingConfigs.getByName("debug")
        }
        debug {
            isMinifyEnabled = false
            isShrinkResources = false   // ✅ fixed
        }
    }
}

flutter {
    source = "../.."
}
