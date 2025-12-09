// android/build.gradle.kts

import org.gradle.api.file.Directory

plugins {
    // 只在根專案加上 Google Services plugin，版本依 Firebase 文件
    id("com.google.gms.google-services") version "4.4.4" apply false
}

// 這段是 Flutter 預設的多模組 build 資料夾設定
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
