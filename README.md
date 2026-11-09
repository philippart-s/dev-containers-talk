# 🗺️ Dev Containers talk steps 🗺️

## 🏗️ Dev Containers installation 🏗️

- Container engine: Rancher Desktop (VM `vz`, engine `moby`, mount type `virtiofs`, admin access disabled)
- Docker context: `docker context use rancher-desktop`
- Registry: `docker login 95y036e0.gra7.container-registry.ovh.net`

## 🔥 Before the talk 🔥

- Prepare the machine from `main` (about 10 minutes): `./bin/prepare-talk.sh`
  - checks the container engine, warms the Docker build cache of every step and of the step-09 template, pulls `postgres:18`, reports leftover demo containers
  - the working tree is not touched (each step is exported with `git archive`)
  - the cache is per step: each set of features builds its own image layers, warming one step does not warm the others
  - any change to a step configuration (`.devcontainer/`) invalidates the cache of that step: `./bin/prepare-talk.sh step-NN`
- Do one full rehearsal in VS Code (`git switch` + `Rebuild Container`) to fill the `vscode` volume (VS Code server and extensions)
- Do not run `docker system prune` / `docker builder prune` or a Rancher Desktop factory reset after the rehearsal
- On D-day: start Rancher Desktop before going on stage
- After step-08: stop the database container (`docker ps`, then `docker stop <name>`), `Rebuild Container` on another step does not stop it

## 📦 Talk resources 📦
  - one clone, one VS Code window: for each step, `git switch step-NN` then `SHIFT + CMD + P`: `Dev Containers: Rebuild Container`
    (`Reopen in Container` would reuse the container of the previous step: same folder, same config path)
  - open in Firefox:
    - https://github.com/devcontainers/feature-starter
    - https://github.com/philippart-s/feature-slidesk-talk
    - https://github.com/devcontainers/template-starter
    - https://github.com/philippart-s/dev-containers-template-talk
  - open a terminal on the host to compare with the containers:
    - `java --version` → Java 27 (host) vs Java 25 (step-00)
    - `ovhcloud version` → latest (host) vs v0.16.0 (containers)
    - `docker context ls` → Rancher Desktop, not Docker Desktop

## 🎉 Init Dev Containers 🎉

### 🪾 step-00 🪾
- Create the Dev Container configuration file: `SHIFT + CMD + P`: `Dev Containers: Add Dev Containers configuration Files...`
  - Choose `Java devcontainers`
  - additional options: `25-trixie`
  - install Maven
- Click `Reopen in Container` (or `SHIFT + CMD + P`: `Dev Containers: Reopen in Container`)
- Open the newly created configuration: `SHIFT + CMD + P`: `Dev Containers: Open Container Configuration File...`
- Test Java configuration:
  - `java --version` → Java 25 (Java 27 on the host)
  - `mvn --version`
  - test with "Hello, World" app: `01-java-hello-world`
  - display ubuntu version: `cat /etc/os-release`
- Remove the generated configuration before switching to step-02: `rm -rf .devcontainer`

### 🪾 step-01 🪾
- Result of step-00 (generated configuration), kept for reference: no live action

## ⚙️ Customize devcontainer.json ⚙️

### 🪾 step-02 🪾
- use Dev Container `base` image
- add java with
  - Maven 3.10.0
  - Java 27
- JBang 0.143.0 with SDKMan
- Set JBang in the path (to be accessible by the extension)
- Configure VSCode:
  - Java 27 path
  - JBang extension
- Test Jbang: `jbang hello@jbangdev world`

## 🧰 Add custom tool: OVHcloud CLI and Httpd 🧰

### 🪾 step-03 🪾
- create the installation script `install-ovh-cli.sh`
- add post command configuration `"OVHcloud CLI": "./.devcontainer/install-ovh-cli.sh"` && `"Httpd": "jbang app setup && jbang app install httpd@jbangdev"` in `postCreateCommand` configuration
- add httpd to PATH: `"PATH": "${containerEnv:PATH}:/usr/local/sdkman/candidates/jbang/current/bin"` in `remoteEnv` configuration
- test OVHcloud CLI: `ovhcloud version`
- test httpd: `httpd`

## 🧩 Create a feature 🧩

### 🪾 step-04 🪾

- create the `ovhcloud-cli` folder in the `.devcontainer` folder
- create the `devcontainer-features.json` file in the `.devcontainer/ovhcloud-cli` folder
- add `install.sh` file
- update the `devcontainer-features.json` file 
- update the `devcontainer.json` file to use the new feature

### 🪾 step-05 🪾

- create the feature-dev-containers-talk project, fork from https://github.com/devcontainers/feature-starter
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
- create and push the image: `docker build -t 95y036e0.gra7.container-registry.ovh.net/library/dev-container-talk:1.2.1 .` && `docker push 95y036e0.gra7.container-registry.ovh.net/library/dev-container-talk:1.2.1`

### 🪾 step-07 🪾

- update the `devcontainer.json` file: `"image": "95y036e0.gra7.container-registry.ovh.net/library/dev-container-talk:1.2.1",`

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

