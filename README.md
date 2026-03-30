# 🗺️ Dev Containers talk steps 🗺️

## 🏗️ Dev Containers installation 🏗️

## 📦 Talk resources 📦
  - open the 12 VSCode projects with [automatic-vscode-opening](./bin/automatic-vscode-opening.sh) script
  - open in Firefox:
    - https://github.com/devcontainers/feature-starter
    - https://github.com/philippart-s/feature-slidesk-talk
    - https://github.com/devcontainers/template-starter
    - https://github.com/philippart-s/dev-containers-template-talk
  - open a bash (to show that Java is not installed)    

## 🎉 Init Dev Containers 🎉

### 🪾 step-00 🪾
- Create the Dev Container configuration file: `SHIFT + CMD + P`: `Dev Containers: Add Dev Containers configuration Files...`
  - Choose `Java devcontainers`
  - additional options: `21-bullseye`
  - install Maven

### 🪾 step-01 🪾
- Open the newly created Dev Containers: `SHIFT + CMD + P`: `Dev Containers: Open Container Configuration File...`
- Test Java configuration:
  - `java --version`
  - `mvn --version`
  - test with "Hello, World" app: `01-java-hello-world`

## ⚙️ Customize devcontainer.json ⚙️

### 🪾 step-02 🪾
- use Dev Container `base` image
- ~~add bat: `xx-add-bat`~~
- add java with
  - Maven 3.9.11
  - Java 25
- JBang with SDKMan
- Set JBang in the path (to be accessible by the extension)
- Configure VSCode:
  - Java 25 path
  - JBang extension
- Test Jbang: `jbang hello@jbangdev world`
