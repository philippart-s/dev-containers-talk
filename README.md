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

## 🧹 Between talks 🧹

- Recover disk space from `main`: `./bin/clean-talk.sh` (`--dry-run` only lists, `--all` also removes the `vscode` volume)
  - removes the demo containers, the step-08 compose network, the talk images, the old step-10 Docker in Docker volume and the whole Docker build cache (other projects included)
  - run `./bin/prepare-talk.sh` again before the next talk

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