# 🗺️ Dev Containers talk steps 🗺️

## 🏗️ Dev Containers installation 🏗️

## 📦 Talk resources 📦
 - open each VSCode on the dedicated project and branch (step-xx) + dev-containers-template-talk and feature-slidesk-talk
 - open each VSCode project with the Dev Containers extension

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
- create and push the image: `docker build -t wilda/dev-container-talk:1.0.0 .` && `docker push wilda/dev-container-talk:1.0.0`

### 🪾 step-07 🪾

- update the `devcontainer.json` file: `"image": "wilda/dev-container-talk:1.0.0",`

### 🪾 step-08 🪾

- create the `docker-compose.yml` file
- update the `devcontainer.json` file: 
```json
"dockerComposeFile": "docker-compose.yml",
	"service": "devcontainer",
	"workspaceFolder": "/workspaces/${localWorkspaceFolderBasename}",
	
	"features": {
		"ghcr.io/robbert229/devcontainer-features/postgresql-client:1": {}
	},
```
- test PSQL connexion: `psql -h localhost -U postgres -d postgres`

## 🪄 Create & use template 🪄

### 🪾 step-09 🪾

- `CMD+SHIFT+P` && `Dev Containers: Add Dev Containers configuration Files...`
- `ghcr.io/philippart-s/dev-containers-template-talk/java-coding:latest`

## ⚡️ Optimization ⚡️

### 🪾 step-10 🪾

- update the `devcontainer.json` file to use custom image: `"image": "wilda/dev-container-talk:1.0.0"`
- add the dev container CLI:
```json
"ghcr.io/eliises/devcontainer-features/devcontainers-cli:1": {
			"version": "latest",
			"nodeVersion": "latest"
		}
```
- add Docker in Docker: `"ghcr.io/devcontainers/features/docker-in-docker:2": {}`
- build and push image: `devcontainer build --workspace-folder . --push false --image-name wilda/devcontainer-base-image-talk:1.0.0`

### 🪾 step-11 🪾

- update the `devcontainer.json` file to use dev container image: `"image": "wilda/devcontainer-base-image-talk:1.0.0"`

## 🗑️ Clean Resources 🗑️ 
