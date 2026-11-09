# 🗺️ Dev Containers talk steps 🗺️

## 🏗️ Dev Containers installation 🏗️

- Container engine: Rancher Desktop (VM `vz`, engine `moby`, mount type `virtiofs`, admin access disabled)
- Docker context: `docker context use rancher-desktop`
- Registry: `docker login 95y036e0.gra7.container-registry.ovh.net`

## 🔥 Before the talk 🔥

- Warm the build cache, for each branch with a `.devcontainer` folder (step-01 to step-08, step-10, step-11):
  `git switch step-NN && npx @devcontainers/cli build --workspace-folder .`
- Do one full rehearsal in VS Code (`git switch` + `Rebuild Container`) to fill the `vscode` volume (VS Code server and extensions)
- step-08: pre-pull the database image: `docker pull postgres:18`
- step-09: apply the template once, then `git restore . && git clean -fd`
- step-10: run the image build once inside the step-10 container (the `dind-var-lib-docker-*` volume keeps its cache)
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
