# 🗺️ Dev Containers talk steps 🗺️

## 🏗️ Dev Containers installation 🏗️

## 📦 Talk resources 📦

## 🎉 Init Dev Containers 🎉
- Create the Dev Container configuration file: `SHIFT + CMD + P`: `Dev Containers: Add Dev Containers configuration Files...`
  - Choose `Java devcontainers`
  - additional options: `21-bullseye`
  - install Maven
- Open the newly created Dev Containers: `SHIFT + CMD + P`: `Dev Containers: Open Container Configuration File...`
- Test Java configuration:
  - `java --version`
  - `mvn --version`
  - test with "Hello, World" app: `01-java-hello-world`

## ⚙️ Customize devcontainer.json ⚙️
- use Ubuntu image
- add bat: `xx-add-bat`
- add java with
  - Maven 3.9.11
  - Java 25
- JBang with SDKMan
- Set JBang in the path (to be accessible by the extension)
- Configure VSCode:
  - Java 25 path
  - JBang extension

## 🧰 Add custom tool: SliDesk and JBang 🧰
- create the installation script `install-slideck.sh`
- add post command configuration `"SliDesk": "./.devcontainer/install-slidesk.sh"` && `"Javelit": "jbang app setup && jbang app install javelit@javelit"` in `postCreateCommand` configuration
- add Javelit to PATH: `"PATH": "${containerEnv:PATH}:/usr/local/sdkman/candidates/jbang/current/bin"` in `remoteEnv` configuration

## 🗑️ Clean Resources 🗑️ 
