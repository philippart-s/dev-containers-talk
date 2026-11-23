#!/bin/bash
# Prepares the demo machine before the talk:
#   - checks the container engine (Rancher Desktop) and the tools,
#   - warms the Docker build cache of each step, of the image built live in step-10 and of the step-09 template,
#   - pulls the images used outside of a build (postgres for step-08),
#   - checks that the VS Code server and the extensions of the talk are in the `vscode` volume,
#     and fills it when needed (full run only): opens step-11 in a VS Code dev container, to be closed afterwards,
#   - reports leftover demo containers.
# The working tree is not touched: each step is exported with `git archive` into a temporary folder.
#
# Usage:
#   ./bin/prepare-talk.sh                 # every step + template + images + VS Code cache
#   ./bin/prepare-talk.sh step-06 step-10 # only these steps (after a change in their .devcontainer/)
#   TALK_VARIANT=php ./bin/prepare-talk.sh  # PHP variant: php/step-NN branches + php-coding template (docs/php-variant.md)
#   ./bin/prepare-talk.sh --vscode          # only the VS Code cache (`vscode` volume)

set -uo pipefail

# step-00 has no configuration (created live), step-01 holds its result; step-09 is the template, warmed apart
# VSCODE_EXTENSIONS: extensions VS Code installs in the dev containers, cached in the `vscode` volume
case "${TALK_VARIANT:-java}" in
  java) PREFIX="";     TEMPLATE_ID=java-coding; TEMPLATE_ARGS='{"imageVariant":"bullseye"}'
        VSCODE_EXTENSIONS=(vscjava.vscode-java-pack jbangdev.jbang-vscode) ;;
  php)  PREFIX="php/"; TEMPLATE_ID=php-coding;  TEMPLATE_ARGS='{"imageVariant":"noble"}'
        VSCODE_EXTENSIONS=(bmewburn.vscode-intelephense-client xdebug.php-debug) ;;
  *) echo "❌ Unknown TALK_VARIANT: $TALK_VARIANT (java or php)"; exit 1 ;;
esac
ALL_STEPS=()
for n in 01 02 03 04 05 06 07 08 10 11 12; do ALL_STEPS+=("${PREFIX}step-$n"); done
TEMPLATE="ghcr.io/philippart-s/dev-containers-template-talk/$TEMPLATE_ID:latest"
PULL_IMAGES=(postgres:18)
DEVCONTAINER_CLI=(npx -y @devcontainers/cli)

REPO_ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)" || exit 1
# Fixed path: for compose configs (step-08) the CLI names an extra image after the folder path,
# a stable path makes each run replace that image instead of adding a new one.
TMP_ROOT="${TMPDIR:-/tmp}"
WORK_DIR="${TMP_ROOT%/}/dev-containers-talk-prepare"
# Kept after the run: it is the workspace of the dev container opened by --vscode
VSCODE_DIR="${TMP_ROOT%/}/dev-containers-talk-vscode"
VSCODE_TIMEOUT=900
rm -rf "$WORK_DIR" && mkdir -p "$WORK_DIR"
FAILURES=()
SUMMARY=()

info()  { printf '\033[1;34m▶ %s\033[0m\n' "$*"; }
ok()    { printf '  ✅ %s\n' "$*"; }
warn()  { printf '  ⚠️  %s\n' "$*"; }
fail()  { printf '  ❌ %s\n' "$*"; }

check_environment() {
  info "Container engine"
  if ! docker info > /dev/null 2>&1; then
    fail "Docker engine unreachable (context: $(docker context show 2>/dev/null)). Start Rancher Desktop, then: docker context use rancher-desktop"
    exit 1
  fi
  ok "context $(docker context show), $(docker info --format '{{.OperatingSystem}}, {{.NCPU}} CPUs')"
  if ! command -v npx > /dev/null 2>&1; then
    fail "npx not found (Node.js is needed to run the dev container CLI)"
    exit 1
  fi
  ok "dev container CLI $("${DEVCONTAINER_CLI[@]}" --version 2>/dev/null)"

  info "Branches"
  git -C "$REPO_ROOT" fetch -q origin || warn "git fetch failed, using local branches"
  for step in "${STEPS[@]}"; do
    if ! git -C "$REPO_ROOT" rev-parse -q --verify "$step" > /dev/null; then
      fail "$step: local branch not found"
      FAILURES+=("$step")
      continue
    fi
    behind=$(git -C "$REPO_ROOT" rev-list --count "$step..origin/$step" 2>/dev/null || echo 0)
    [ "$behind" -gt 0 ] && warn "$step is $behind commit(s) behind origin/$step (run bin/automatic-branches-pull.sh)"
  done
}

# $1: label, $2: folder to build, then extra arguments for `devcontainer build`
build() {
  local label=$1 dir=$2 start rc
  shift 2
  start=$(date +%s)
  # stable image name: each run replaces the previous image instead of adding a new vsc-<folder>-<hash> one
  "${DEVCONTAINER_CLI[@]}" build --workspace-folder "$dir" --image-name "dev-containers-talk/$label:prepare" "$@" > "$WORK_DIR/$label.log" 2>&1
  rc=$?
  local seconds=$(( $(date +%s) - start ))
  if [ $rc -eq 0 ]; then
    ok "$label (${seconds}s)"
    SUMMARY+=("$label ✅ ${seconds}s")
  else
    fail "$label (${seconds}s), log: $WORK_DIR/$label.log"
    SUMMARY+=("$label ❌ ${seconds}s")
    FAILURES+=("$label")
  fi
}

warm_steps() {
  info "Build cache of the steps"
  for step in "${STEPS[@]}"; do
    git -C "$REPO_ROOT" rev-parse -q --verify "$step" > /dev/null || continue
    mkdir -p "$WORK_DIR/$step"
    git -C "$REPO_ROOT" archive "$step" | tar -x -C "$WORK_DIR/$step"
    build "$step" "$WORK_DIR/$step"
  done
}

# step-10 builds the image of step-11 live, from its dev container: Docker outside of Docker uses the same
# engine and build cache as the host, so building the same configuration here warms the live build.
warm_step10_image() {
  local dir="$WORK_DIR/${PREFIX}step-10"
  [ -f "$dir/.devcontainer/image/devcontainer.json" ] || return 0
  info "Build cache of the image built live in ${PREFIX}step-10"
  build "${PREFIX}step-10-image" "$dir" --config "$dir/.devcontainer/image/devcontainer.json"
}

warm_template() {
  info "Build cache of the step-09 template ($TEMPLATE_ID)"
  local label="${PREFIX}step-09-template"
  local dir="$WORK_DIR/$label"
  mkdir -p "$dir"
  if ! "${DEVCONTAINER_CLI[@]}" templates apply -t "$TEMPLATE" -w "$dir" -a "$TEMPLATE_ARGS" > "$WORK_DIR/$label-apply.log" 2>&1; then
    fail "template apply, log: $WORK_DIR/$label-apply.log"
    FAILURES+=("$label")
    return
  fi
  build "$label" "$dir"
}

pull_images() {
  info "Images used outside of a build"
  for image in "${PULL_IMAGES[@]}"; do
    if docker pull -q "$image" > /dev/null 2>&1; then
      ok "$image"
    else
      fail "$image"
      FAILURES+=("$image")
    fi
  done
}

code_cli() {
  local app
  if command -v code > /dev/null 2>&1; then command -v code; return; fi
  for app in "/Applications/Visual Studio Code.app" "$HOME/Applications/Visual Studio Code.app"; do
    [ -x "$app/Contents/Resources/app/bin/code" ] && { echo "$app/Contents/Resources/app/bin/code"; return; }
  done
  return 1
}

# Prints what the `vscode` volume lacks for the local VS Code and the extensions of the variant (nothing = complete).
# The volume is read through an image already present, to avoid pulling one.
vscode_cache_missing() {
  local commit=$1 probe content ext
  if ! docker volume inspect vscode > /dev/null 2>&1; then echo "the vscode volume"; return; fi
  probe=$(docker images --format '{{.Repository}}:{{.Tag}}' | grep -E '^(dev-containers-talk/|postgres:|mcr\.microsoft\.com/devcontainers/)' | head -1)
  if [ -z "$probe" ]; then echo "(no local image to read the volume)"; return; fi
  content=$(docker run --rm --entrypoint ls -v vscode:/v "$probe" -1 /v/vscode-server/bin/linux-arm64 /v/vscode-server/extensionsCache 2>/dev/null)
  grep -qx "$commit" <<< "$content" || echo "VS Code server $commit"
  for ext in "${VSCODE_EXTENSIONS[@]}"; do
    grep -q "^$ext-" <<< "$content" || echo "$ext"
  done
}

check_vscode_cache() {
  info "VS Code cache (vscode volume)"
  local code commit missing
  if ! code=$(code_cli); then warn "VS Code CLI not found, cache not checked"; VSCODE_TODO=true; return; fi
  read -r version commit < <("$code" --version | head -2 | tr '\n' ' ')
  missing=$(vscode_cache_missing "$commit")
  if [ -z "$missing" ]; then
    ok "VS Code $version server and extensions (${VSCODE_EXTENSIONS[*]})"
  else
    warn "missing for VS Code $version: $(tr '\n' ',' <<< "$missing" | sed 's/,$//; s/,/, /g')"
    VSCODE_TODO=true
  fi
}

# Opens step-11 (its image carries every extension of the variant) in a VS Code dev container,
# then waits until the server and the extensions are in the `vscode` volume.
fill_vscode_cache() {
  info "Filling the VS Code cache with ${PREFIX}step-11"
  local code version commit dir hex waited=0 missing
  code=$(code_cli) || { fail "VS Code CLI not found"; return 1; }
  read -r version commit < <("$code" --version | head -2 | tr '\n' ' ')
  missing=$(vscode_cache_missing "$commit")
  if [ -z "$missing" ]; then ok "already complete for VS Code $version"; return; fi
  dir="$VSCODE_DIR/${PREFIX}step-11"
  rm -rf "$dir" && mkdir -p "$dir"
  git -C "$REPO_ROOT" archive "${PREFIX}step-11" | tar -x -C "$dir" || { fail "${PREFIX}step-11: local branch not found"; return 1; }
  # Undocumented URI scheme of the Dev Containers extension: dev-container+<JSON in hex>/<folder in the container>.
  # The Docker context must be in the JSON: opened this way, the extension skips its own context detection
  # and falls back to the `default` context (/var/run/docker.sock, absent with Rancher Desktop).
  hex=$(printf '{"hostPath":"%s","localDocker":false,"settings":{"context":"%s"}}' "$dir" "$(docker context show)" | xxd -p | tr -d '\n')
  "$code" --new-window --folder-uri "vscode-remote://dev-container+$hex/workspaces/$(basename "$dir")"
  echo "  VS Code opens ${PREFIX}step-11 in a dev container, waiting for: $(tr '\n' ',' <<< "$missing" | sed 's/,$//; s/,/, /g')"
  while [ -n "$missing" ] && [ $waited -lt $VSCODE_TIMEOUT ]; do
    sleep 10; waited=$((waited + 10))
    missing=$(vscode_cache_missing "$commit")
  done
  if [ -n "$missing" ]; then
    fail "still missing after ${VSCODE_TIMEOUT}s: $(tr '\n' ' ' <<< "$missing")"
    return 1
  fi
  ok "VS Code $version server and extensions cached (${waited}s), you can close the VS Code window"
}

check_leftovers() {
  info "Leftover demo containers"
  local running
  running=$(docker ps --format '{{.Names}} ({{.Image}})' | grep -iE 'devcontainer|vsc-' || true)
  if [ -n "$running" ]; then
    warn "still running (docker stop <name> to free memory):"
    printf '     %s\n' "$running"
  else
    ok "none"
  fi
}

VSCODE_TODO=false
if [ "${1:-}" = "--vscode" ]; then
  docker info > /dev/null 2>&1 || { fail "Docker engine unreachable: start Rancher Desktop"; exit 1; }
  fill_vscode_cache || exit 1
  exit 0
fi

if [ $# -gt 0 ]; then
  STEPS=("$@")
  FULL=false
else
  STEPS=("${ALL_STEPS[@]}")
  FULL=true
fi

check_environment
warm_steps
warm_step10_image
if $FULL; then
  warm_template
  pull_images
fi
check_vscode_cache
# Full run: fill the cache when it is incomplete (a partial run only reports it)
if $FULL && $VSCODE_TODO && code_cli > /dev/null; then
  if fill_vscode_cache; then
    VSCODE_TODO=false
    SUMMARY+=("vscode-cache ✅")
  else
    SUMMARY+=("vscode-cache ❌")
    FAILURES+=("vscode-cache")
  fi
fi
check_leftovers

info "Summary"
printf '  %s\n' "${SUMMARY[@]}"
if $VSCODE_TODO; then
  echo
  echo "  VS Code cache incomplete: ${TALK_VARIANT:+TALK_VARIANT=$TALK_VARIANT }./bin/prepare-talk.sh --vscode (or one rehearsal in VS Code)"
fi
if [ ${#FAILURES[@]} -gt 0 ]; then
  echo
  fail "failed: ${FAILURES[*]} (logs in $WORK_DIR)"
  exit 1
fi
rm -rf "$WORK_DIR"
