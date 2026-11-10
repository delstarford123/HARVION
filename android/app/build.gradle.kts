import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = when {
    rootProject.file("key.properties").exists() -> rootProject.file("key.properties")
    file("../key.properties").exists() -> file("../key.properties")
    file("key.properties").exists() -> file("key.properties")
    else -> rootProject.file("key.properties")
}
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    println("[HARVION Signing] Loaded key.properties from: ${keystorePropertiesFile.absolutePath}")
} else {
    println("[HARVION Signing] WARNING: key.properties not found!")
}

android {
    namespace = "com.delstarfordworks.vine"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.delstarfordworks.vine"
        
        // PRODUCTION FIX: Raised to 23 to support Firebase and Audio Streaming
        minSdk = flutter.minSdkVersion
        
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                val rawStoreFile = keystoreProperties["storeFile"] as String
                storeFile = when {
                    file(rawStoreFile).exists() -> file(rawStoreFile)
                    file("upload-keystore.jks").exists() -> file("upload-keystore.jks")
                    rootProject.file("app/upload-keystore.jks").exists() -> rootProject.file("app/upload-keystore.jks")
                    else -> file(rawStoreFile)
                }
                storePassword = keystoreProperties["storePassword"] as String
                println("[HARVION Signing] Release signing configured with keystore: ${storeFile?.absolutePath} (alias: $keyAlias)")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
