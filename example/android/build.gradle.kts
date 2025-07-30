allprojects {
    repositories {
        google()
        mavenCentral()
        flatDir {
            // Adjust the path to point to the plugin's libs folder
            dirs(
                project(":infineon_nfc_lock_control").projectDir.resolve("libs")
            )
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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
