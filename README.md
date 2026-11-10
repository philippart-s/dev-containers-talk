# 🗺️ Dev Containers talk steps (PHP variant) 🗺️

> PHP variant of the talk (`php/step-NN` branches). The main talk is the Java one (`step-NN` branches), see [docs/php-variant.md](https://github.com/philippart-s/dev-containers-talk/blob/main/docs/php-variant.md).

## 🏗️ Dev Containers installation 🏗️

- Container engine: Rancher Desktop (VM `vz`, engine `moby`, mount type `virtiofs`, admin access disabled)
- Docker context: `docker context use rancher-desktop`
- Registry: `docker login 95y036e0.gra7.container-registry.ovh.net`

## 🔥 Before the talk 🔥

- Prepare the machine from `main`: `TALK_VARIANT=php ./bin/prepare-talk.sh`
  - checks the container engine, warms the Docker build cache of every `php/step-NN` branch and of the step-09 template, pulls `postgres:18`, reports leftover demo containers
  - the PHP feature compiles PHP and Xdebug from source: a cold build takes about 4 minutes per step, the warm-up is mandatory
  - any change to a step configuration (`.devcontainer/`) invalidates the cache of that step: `./bin/prepare-talk.sh php/step-NN`
- Do one full rehearsal in VS Code (`git switch` + `Rebuild Container`) to fill the `vscode` volume (VS Code server and extensions)
- Do not run `docker system prune` / `docker builder prune` or a Rancher Desktop factory reset after the rehearsal
- On D-day: start Rancher Desktop before going on stage
- After step-08: stop the database container (`docker ps`, then `docker stop <name>`), `Rebuild Container` on another step does not stop it

## 🧹 Between talks 🧹

- Recover disk space from `main`: `./bin/clean-talk.sh` (`--dry-run` only lists, `--all` also removes the `vscode` volume)
  - removes the demo containers, the step-08 compose network, the talk images (Java and PHP), the old step-10 Docker in Docker volume and the whole Docker build cache (other projects included)
  - run `TALK_VARIANT=php ./bin/prepare-talk.sh` again before the next talk

## 📦 Talk resources 📦
  - one clone, one VS Code window: for each step, `git switch php/step-NN` then `SHIFT + CMD + P`: `Dev Containers: Rebuild Container`
    (`Reopen in Container` would reuse the container of the previous step: same folder, same config path)
  - open in Firefox:
    - https://github.com/devcontainers/feature-starter
    - https://github.com/philippart-s/feature-slidesk-talk
    - https://github.com/devcontainers/template-starter
    - https://github.com/philippart-s/dev-containers-template-talk
  - open a terminal on the host to compare with the containers:
    - `php --version` and `composer --version` → not installed on the host vs PHP 8.5 and Composer in the containers
    - `ovhcloud version` → latest (host) vs v0.16.0 (containers)
    - `docker context ls` → Rancher Desktop, not Docker Desktop

## 🎉 Init Dev Containers 🎉

### 🪾 step-00 🪾
- Create the Dev Container configuration file: `SHIFT + CMD + P`: `Dev Containers: Add Dev Containers configuration Files...`
  - Choose `PHP`
  - additional options: `8.5-trixie`
- Click `Reopen in Container` (or `SHIFT + CMD + P`: `Dev Containers: Reopen in Container`)
- Open the newly created configuration: `SHIFT + CMD + P`: `Dev Containers: Open Container Configuration File...`
- Test PHP configuration:
  - `php --version` → PHP 8.5 (not installed on the host)
  - `composer --version`
  - test with "Hello, World" script: `php scripts/hello-world.php`
  - display debian version: `cat /etc/os-release`
- Remove the generated configuration before switching to step-02: `rm -rf .devcontainer`

### 🪾 step-01 🪾
- Result of step-00 (generated configuration), kept for reference: no live action
