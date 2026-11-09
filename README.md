# 🗺️ Dev Containers talk steps 🗺️

## 🏗️ Dev Containers installation 🏗️

- Container engine: Rancher Desktop (VM `vz`, engine `moby`, mount type `virtiofs`, admin access disabled)
- Docker context: `docker context use rancher-desktop`
- Registry: `docker login 95y036e0.gra7.container-registry.ovh.net`

## 🔥 Before the talk 🔥

- Warm the build cache, for each branch with a `.devcontainer` folder (step-01 to step-08, step-10, step-11):
  `git switch step-NN && npx @devcontainers/cli build --workspace-folder .`
- Do one full rehearsal in VS Code (`git switch` + `Rebuild Container`) to fill the `vscode` volume (VS Code server and extensions)
- step-09: apply the template once, then `git restore . && git clean -fd`
- Do not run `docker system prune` / `docker builder prune` or a Rancher Desktop factory reset after the rehearsal
- On D-day: start Rancher Desktop before going on stage

## 📦 Talk resources 📦
  - one clone, one VS Code window: for each step, `git switch step-NN` then `SHIFT + CMD + P`: `Dev Containers: Rebuild Container`
    (`Reopen in Container` would reuse the container of the previous step: same folder, same config path)
  - open in Firefox:
    - https://github.com/devcontainers/feature-starter
    - https://github.com/philippart-s/feature-slidesk-talk
    - https://github.com/devcontainers/template-starter
    - https://github.com/philippart-s/dev-containers-template-talk
  - open a terminal on the host to compare with the containers:
    - `java --version` → Java 27 (host) vs Java 25 (step-01) / Java 26 (step-02 and later)
    - `ovhcloud version` → latest (host) vs v0.16.0 (containers)
    - `docker context ls` → Rancher Desktop, not Docker Desktop

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
  - display ubuntu version: `cat /etc/os-release`
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
