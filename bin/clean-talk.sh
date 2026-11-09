#!/bin/bash
# Removes everything the talk left in the container engine, to recover disk space between talks:
#   - demo containers (VS Code dev containers of this repository, step-08 compose project),
#   - the step-08 compose network,
#   - talk images (VS Code builds, bin/prepare-talk.sh builds, Harbor images, base images, postgres),
#   - the old step-10 Docker in Docker volume and unused anonymous volumes,
#   - the whole Docker build cache (not only the talk's: Docker cannot prune it per project).
# Run ./bin/prepare-talk.sh afterwards to warm everything again.
#
# Usage:
#   ./bin/clean-talk.sh            # show what will be removed, ask for confirmation
#   ./bin/clean-talk.sh --dry-run  # only show what would be removed
#   ./bin/clean-talk.sh --yes      # no confirmation
#   ./bin/clean-talk.sh --all      # also remove the `vscode` volume (VS Code server cache shared by all dev containers)

set -uo pipefail

REPO_ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)" || exit 1
COMPOSE_PROJECT="$(basename "$REPO_ROOT")_devcontainer"
IMAGE_PATTERN='^(vsc-(dev-containers-talk|step-[0-9]{2}(-template)?)-[0-9a-f]+(-features)?|dev-containers-talk/step-[0-9]{2}(-template)?|check-step-[0-9]{2}|95y036e0\.gra7\.container-registry\.ovh\.net/library/(dev-container-talk|devcontainer-base-image-talk)|mcr\.microsoft\.com/devcontainers/(base|java)|postgres):'

DRY_RUN=false
ASSUME_YES=false
WITH_VSCODE_VOLUME=false
for arg in "$@"; do
  case $arg in
    --dry-run) DRY_RUN=true ;;
    --yes|-y) ASSUME_YES=true ;;
    --all) WITH_VSCODE_VOLUME=true ;;
    *) echo "Unknown option: $arg (see the header of $0)"; exit 1 ;;
  esac
done

info() { printf '\033[1;34m▶ %s\033[0m\n' "$*"; }
list() { if [ -n "$1" ]; then printf '%s\n' "$1" | sed 's/^/    /'; else echo "    (none)"; fi; }

if ! docker info > /dev/null 2>&1; then
  echo "❌ Docker engine unreachable (context: $(docker context show 2>/dev/null)). Start Rancher Desktop first."
  exit 1
fi

# --- Inventory ---------------------------------------------------------------
IMAGES=$(docker images --format '{{.Repository}}:{{.Tag}}' | grep -E "$IMAGE_PATTERN" | sort -u)

CONTAINERS=$(
  {
    docker ps -aq --filter "label=devcontainer.local_folder=$REPO_ROOT"
    docker ps -aq --filter "label=com.docker.compose.project=$COMPOSE_PROJECT"
    for image in $IMAGES; do docker ps -aq --filter "ancestor=$image"; done
  } | sort -u
)
CONTAINER_NAMES=$(for id in $CONTAINERS; do docker inspect --format '{{.Name}} ({{.Config.Image}})' "$id" | sed 's#^/##'; done)

NETWORKS=$(docker network ls --format '{{.Name}}' --filter "label=com.docker.compose.project=$COMPOSE_PROJECT")

VOLUMES=$(docker volume ls --format '{{.Name}}' | grep -E '^dind-var-lib-docker-' || true)
$WITH_VSCODE_VOLUME && VOLUMES=$(printf '%s\n%s' "$VOLUMES" "$(docker volume ls -q --filter name='^vscode$')" | sed '/^$/d')

info "Disk usage before"
docker system df

info "Containers to remove"
list "$CONTAINER_NAMES"
info "Networks to remove"
list "$NETWORKS"
info "Images to remove"
list "$IMAGES"
info "Volumes to remove (plus unused anonymous volumes)"
list "$VOLUMES"
info "Build cache"
echo "    all of it ($(docker system df --format '{{if eq .Type "Build Cache"}}{{.Size}}{{end}}' | sed '/^$/d')), including other projects' cache"

if $DRY_RUN; then
  echo
  echo "Dry run: nothing removed."
  exit 0
fi

if ! $ASSUME_YES; then
  echo
  read -r -p "Remove all of the above? [y/N] " answer
  [[ "$answer" =~ ^[yYoO]$ ]] || { echo "Cancelled."; exit 0; }
fi

# --- Removal (containers first: they hold images, networks and volumes) -------
info "Removing"
[ -n "$CONTAINERS" ] && docker rm -f $CONTAINERS > /dev/null && echo "  ✅ containers"
[ -n "$NETWORKS" ] && docker network rm $NETWORKS > /dev/null && echo "  ✅ networks"
[ -n "$IMAGES" ] && docker rmi -f $IMAGES > /dev/null && echo "  ✅ images"
docker image prune -f > /dev/null && echo "  ✅ dangling images"
[ -n "$VOLUMES" ] && docker volume rm $VOLUMES > /dev/null && echo "  ✅ volumes"
docker volume prune -f > /dev/null && echo "  ✅ unused anonymous volumes"
docker builder prune -af > /dev/null && echo "  ✅ build cache"

info "Disk usage after"
docker system df
