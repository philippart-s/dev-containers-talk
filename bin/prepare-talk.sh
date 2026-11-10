#!/bin/bash
# Prepares the demo machine before the talk:
#   - checks the container engine (Rancher Desktop) and the tools,
#   - warms the Docker build cache of each step and of the step-09 template,
#   - pulls the images used outside of a build (postgres for step-08),
#   - reports leftover demo containers.
# The working tree is not touched: each step is exported with `git archive` into a temporary folder.
#
# Usage:
#   ./bin/prepare-talk.sh                 # every step + template + images
#   ./bin/prepare-talk.sh step-06 step-10 # only these steps (after a change in their .devcontainer/)

set -uo pipefail

ALL_STEPS=(step-01 step-02 step-03 step-04 step-05 step-06 step-07 step-08 step-10 step-11)
TEMPLATE="ghcr.io/philippart-s/dev-containers-template-talk/java-coding:latest"
TEMPLATE_ARGS='{"imageVariant":"bullseye"}'
PULL_IMAGES=(postgres:18)
DEVCONTAINER_CLI=(npx -y @devcontainers/cli)

REPO_ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)" || exit 1
# Fixed path: for compose configs (step-08) the CLI names an extra image after the folder path,
# a stable path makes each run replace that image instead of adding a new one.
WORK_DIR="${TMPDIR:-/tmp}/dev-containers-talk-prepare"
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

# $1: label, $2: folder to build
build() {
  local label=$1 dir=$2 start rc
  start=$(date +%s)
  # stable image name: each run replaces the previous image instead of adding a new vsc-<folder>-<hash> one
  "${DEVCONTAINER_CLI[@]}" build --workspace-folder "$dir" --image-name "dev-containers-talk/$label:prepare" > "$WORK_DIR/$label.log" 2>&1
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

warm_template() {
  info "Build cache of the step-09 template"
  local dir="$WORK_DIR/step-09-template"
  mkdir -p "$dir"
  if ! "${DEVCONTAINER_CLI[@]}" templates apply -t "$TEMPLATE" -w "$dir" -a "$TEMPLATE_ARGS" > "$WORK_DIR/step-09-template-apply.log" 2>&1; then
    fail "template apply, log: $WORK_DIR/step-09-template-apply.log"
    FAILURES+=("step-09-template")
    return
  fi
  build "step-09-template" "$dir"
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

if [ $# -gt 0 ]; then
  STEPS=("$@")
  FULL=false
else
  STEPS=("${ALL_STEPS[@]}")
  FULL=true
fi

check_environment
warm_steps
if $FULL; then
  warm_template
  pull_images
fi
check_leftovers

info "Summary"
printf '  %s\n' "${SUMMARY[@]}"
if $FULL; then
  echo
  echo "  Still to do by hand:"
  echo "   - one rehearsal in VS Code (git switch + Rebuild Container) to install the VS Code server and extensions"
fi
if [ ${#FAILURES[@]} -gt 0 ]; then
  echo
  fail "failed: ${FAILURES[*]} (logs in $WORK_DIR)"
  exit 1
fi
rm -rf "$WORK_DIR"
