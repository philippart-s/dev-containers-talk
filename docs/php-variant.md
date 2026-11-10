# PHP variant of the talk

The main talk is the Java one (`step-NN` branches). For a PHP audience (first use: AFUP Tours meetup), the `php/step-NN` branches replace Java, Maven and JBang with PHP tools. Everything that does not depend on the language is unchanged: OVHcloud CLI script and feature, step-06 Dockerfile and `dev-container-talk:1.2.1` image, step-08 compose file with Postgres, step-12 security settings.

## Branches

- `php/step-NN` is created from `step-NN` and has a single commit on top of it: the language part of `.devcontainer/devcontainer.json`, `scripts/hello-world.php` instead of `scripts/HelloWorld.java`, and a partial README.
- The full PHP script of the talk is the README of `php/step-12`.
- After a change on a Java step, replay the PHP commit on top of it: `git rebase step-NN php/step-NN` (conflicts are limited to `devcontainer.json` and the README).

## Java → PHP

| Java (`step-NN`) | PHP (`php/step-NN`) |
|---|---|
| step-00: `Java` template, `25-trixie`, Maven | `PHP` template, `8.5-trixie` (`mcr.microsoft.com/devcontainers/php` image, PHP precompiled) |
| `ghcr.io/devcontainers/features/java:1` (Java 27, Maven 3.10.0) | `ghcr.io/devcontainers/features/php:1` (PHP 8.5, Composer and Xdebug, compiled from source) |
| `ghcr.io/devcontainers-extra/features/jbang-sdkman:2`, `jbang hello@jbangdev world` | `ghcr.io/shyim/devcontainers-features/symfony-cli:0`, `symfony check:requirements` |
| step-03: `jbang app install httpd@jbangdev`, JBang folder in `PATH` | `composer global require phpstan/phpstan`, `/home/vscode/.composer/vendor/bin` in `PATH`; web server: `php -S 0.0.0.0:8080 -t scripts` |
| VS Code: `JavaSE-27` runtime, JBang and Java pack extensions | `php.validate.executablePath`, Intelephense and Xdebug extensions, `XDEBUG_MODE=off` in `remoteEnv` |
| step-09: `java-coding` template | `php-coding` template (same repository: `philippart-s/dev-containers-template-talk`) |
| step-10/11/12: `devcontainer-base-image-talk:1.6.1` | `devcontainer-php-image-talk:1.0.0` |

Xdebug is turned off with `XDEBUG_MODE=off`: with the feature defaults (`xdebug.mode=debug`, `start_with_request=yes`), every `php` command prints a "Could not connect to debugging client" warning. To debug: `XDEBUG_MODE=debug php …`. The `mcr.microsoft.com/devcontainers/php` image of step-00/01 has the same behaviour: the warning shows up live, before step-02 turns Xdebug off.

## Preparation

- `TALK_VARIANT=php ./bin/prepare-talk.sh` from `main`: warms `php/step-01` … `php/step-12` (except `php/step-09`) and the `php-coding` template, pulls `postgres:18`.
- One step only: `./bin/prepare-talk.sh php/step-06`.
- The PHP feature compiles PHP from source: about 4 minutes per step on a cold cache (MacBook Air M3, 4 CPUs for the VM). Steps whose features start the same way (`base:noble` + PHP 8.5) reuse the compiled layer.
- `./bin/clean-talk.sh` removes the images of both variants.
- On the host, PHP and Composer are not installed: `php --version` → `command not found`, to compare with the containers.

## Image of step-10

From `php/step-10`, in the dev container:

```bash
devcontainer build --workspace-folder . --config .devcontainer/image/devcontainer.json --push false \
  --image-name 95y036e0.gra7.container-registry.ovh.net/library/devcontainer-php-image-talk:1.0.0
docker push 95y036e0.gra7.container-registry.ovh.net/library/devcontainer-php-image-talk:1.0.0
```

Then report the digest of the pushed image in `.devcontainer/devcontainer.json` and in the README of `php/step-12`:
`docker inspect --format '{{index .RepoDigests 0}}' 95y036e0.gra7.container-registry.ovh.net/library/devcontainer-php-image-talk:1.0.0`.
With the Harbor tag immutability rule, a new image needs a new tag (`1.0.1`, …).
