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
// jni (pulled in by file_picker) pins Flutter's default NDK 28.2. Build against the
// 27.x already installed instead of downloading 5 GB. afterEvaluate, so it wins over
// the plugin's own `ndkVersion flutter.ndkVersion`.
subprojects {
    afterEvaluate {
        extensions.findByName("android")?.let { android ->
            android.javaClass.getMethod("setNdkVersion", String::class.java).invoke(android, "27.0.12077973")
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
