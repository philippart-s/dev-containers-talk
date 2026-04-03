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
  - display ubuntu version: cat /etc/os-release

## ⚙️ Customize devcontainer.json ⚙️

### 🪾 step-02 🪾
- use Dev Container `base` image
- add java with
  - Maven 3.9.14
  - Java 25
- JBang with SDKMan
- Set JBang in the path (to be accessible by the extension)
- Configure VSCode:
  - Java 25 path
  - JBang extension
- Test Jbang: `jbang hello@jbangdev world`

## 🧰 Add custom tool: SliDesk and Javelit 🧰

### 🪾 step-03 🪾
- create the installation script `install-slideck.sh`
- add post command configuration `"SliDesk": "./.devcontainer/install-slidesk.sh"` && `"Javelit": "jbang app setup && jbang app install javelit@javelit"` in `postCreateCommand` configuration
- add Javelit to PATH: `"PATH": "${containerEnv:PATH}:/usr/local/sdkman/candidates/jbang/current/bin"` in `remoteEnv` configuration
- test SliDesk: `slidesk --version`
- test Javelit: `javelit hello`

## 🧩 Create a feature 🧩

### 🪾 step-04 🪾

- create the `slidesk` folder in the `.devcontainer` folder
- create the `devcontainer-features.json` file in the `.devcontainer/slidesk` folder
- add `install.sh` file
- update the `devcontainer-features.json` file 
- update the `devcontainer.json` file to use the new feature

### 🪾 step-05 🪾

- create the feature-slidesk-talk project, fork from https://github.com/devcontainers/feature-starter
- Allow GitHub Actions to create and approve pull requests should be enabled in the repository's `Settings > Actions > General > Workflow` permissions for auto generation of src/<feature>/README.md per Feature
- run manually the `release` workflow
- set the feature package public in the GH repository
- update the `devcontainer.json` file to use the deployed feature

## 🐳 Use custom images 🐳

### 🪾 step-06 🪾

- create the `Dockerfile`
- update the `devcontainer.json` file:
```json
"build": {
		"dockerfile": "Dockerfile"
	},
```
- create and push the image: `docker buildx build --platform="linux/arm64"  -t 95y036e0.gra7.container-registry.ovh.net/library/dev-container-talk:1.0.0 . --push`

### 🪾 step-07 🪾

- update the `devcontainer.json` file: `"image": "95y036e0.gra7.container-registry.ovh.net/library/dev-container-talk:1:0",`
