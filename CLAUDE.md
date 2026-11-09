# Dev Containers talk — demo repository

- Live demo for a talk on Dev Containers (IDE as code). Each branch `step-00` … `step-11` is one demo step; `step-11` is the final state.
- `README.md` is the step-by-step script. It is edited on `main`, then copied to every step branch with `bin/automatic-branches-update.sh` (run by Stéphane, it commits and pushes).
- Demo machine: MacBook Air M3 16 GB, Rancher Desktop (`moby`, `vz`, `virtiofs`, no admin access). Java 27 and the latest `ovhcloud` CLI are installed on the host; containers use Java 25/26 and `ovhcloud` v0.16.0.
- One clone, one VS Code window: `git switch step-NN` then `Dev Containers: Rebuild Container`. Fast only if the Docker build cache was warmed beforehand.
- Images are pushed to the OVHcloud Harbor registry `95y036e0.gra7.container-registry.ovh.net/library/`.
- Related repos: `../dev-containers-template-talk` (template, step-09), `../feature-dev-containers-talk` (feature, step-05).
