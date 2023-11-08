import co.touchlab.skie.configuration.SealedInterop
import co.touchlab.skie.configuration.EnumInterop

plugins {
    kotlin("multiplatform")
    id("com.android.library")
    id("co.touchlab.skie") version "0.5.2"
}

@OptIn(org.jetbrains.kotlin.gradle.ExperimentalKotlinGradlePluginApi::class)
kotlin {
    targetHierarchy.default()

    androidTarget {
        compilations.all {
            kotlinOptions {
                jvmTarget = "1.8"
            }
        }
    }
    
    listOf(
        iosX64(),
        iosArm64(),
        iosSimulatorArm64()
    ).forEach {
        it.binaries.framework {
            baseName = "shared"
        }
    }

    sourceSets {
        val commonMain by getting {
            dependencies {
                implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3")
                implementation("co.touchlab.skie:configuration-annotations:0.5.2")
            }
        }
        val commonTest by getting {
            dependencies {
                implementation(kotlin("test"))
            }
        }
    }
}

skie {
    analytics {
        disableUpload.set(true)
        enabled.set(false)
    }
    features {
        group("co.touchlab.skie.types") {
            SealedInterop.Enabled(true)
            EnumInterop.Enabled(true)
        }
    }
}

android {
    namespace = "com.example.kmp_skie_spike"
    compileSdk = 33
    defaultConfig {
        minSdk = 24
    }
}