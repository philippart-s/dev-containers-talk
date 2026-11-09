# Dev Containers talk — demo repository

- Live demo for a talk on Dev Containers (IDE as code). Each branch `step-00` … `step-11` is one demo step; `step-11` is the final state.
- `README.md` is the step-by-step script. The full version lives on `main`; each `step-NN` branch keeps a partial README that stops at its own step. Do not sync the README across branches (`bin/automatic-branches-update.sh` would overwrite the partial versions).
- Never work directly on `main`: use a work branch. `step-*` branches can be edited directly.
- Demo machine: MacBook Air M3 16 GB, Rancher Desktop (`moby`, `vz`, `virtiofs`, no admin access). Java 27 and the latest `ovhcloud` CLI are installed on the host; containers use Java 25/26 and `ovhcloud` v0.16.0.
- One clone, one VS Code window: `git switch step-NN` then `Dev Containers: Rebuild Container`. Fast only if the Docker build cache was warmed beforehand.
- Images are pushed to the OVHcloud Harbor registry `95y036e0.gra7.container-registry.ovh.net/library/`.
- Related repos: `../dev-containers-template-talk` (template, step-09), `../feature-dev-containers-talk` (feature, step-05).
