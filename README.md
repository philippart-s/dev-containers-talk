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

## ⚙️ Customize devcontainer.json ⚙️

### 🪾 step-02 🪾
- use Dev Container `base` image
- add PHP 8.5 with the `php` feature (Composer and Xdebug included, compiled from source)
- Symfony CLI with the `symfony-cli` feature
- Turn Xdebug off by default: `"XDEBUG_MODE": "off"` in `remoteEnv` configuration (`XDEBUG_MODE=debug php …` to debug)
- Configure VSCode:
  - PHP path for validation
  - Intelephense and Xdebug extensions
- Test Symfony CLI: `symfony check:requirements`

## 🧰 Add custom tool: OVHcloud CLI and PHPStan 🧰

### 🪾 step-03 🪾
- create the installation script `install-ovh-cli.sh`
- add post command configuration `"OVHcloud CLI": "./.devcontainer/install-ovh-cli.sh"` && `"PHPStan": "composer global require phpstan/phpstan"` in `postCreateCommand` configuration
- add the Composer global tools to PATH: `"PATH": "${containerEnv:PATH}:/home/vscode/.composer/vendor/bin"` in `remoteEnv` configuration
- test OVHcloud CLI: `ovhcloud version`
- test PHPStan: `phpstan analyse scripts --level=max`
- test the PHP built-in web server: `php -S 0.0.0.0:8080 -t scripts`, then open http://localhost:8080/hello-world.php

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
- `ghcr.io/philippart-s/dev-containers-template-talk/php-coding:latest`

## ⚡️ Optimization ⚡️

### 🪾 step-10 🪾

- update the `devcontainer.json` file to use custom image: `"image": "95y036e0.gra7.container-registry.ovh.net/library/dev-container-talk:1.2.1"`
- add Node and the dev container CLI (the CLI feature can no longer install Node by itself):
```json
"ghcr.io/devcontainers/features/node:1": {},
"ghcr.io/eliises/devcontainer-features/devcontainers-cli:1": {
			"version": "latest",
			"nodeVersion": "latest"
		}
```
- add Docker outside of Docker: `"ghcr.io/devcontainers/features/docker-outside-of-docker:1": {}` (the build uses the Rancher Desktop engine and its cache)
- create the image configuration `.devcontainer/image/devcontainer.json`: same tools without Docker outside of Docker and the dev container CLI
- build the image: `devcontainer build --workspace-folder . --config .devcontainer/image/devcontainer.json --push false --image-name 95y036e0.gra7.container-registry.ovh.net/library/devcontainer-php-image-talk:1.0.0`
- PHP is compiled once, in the image: the containers created from it no longer compile it

### 🪾 step-11 🪾

- update the `devcontainer.json` file to use dev container image: `"image": "95y036e0.gra7.container-registry.ovh.net/library/devcontainer-php-image-talk:1.0.0"`
