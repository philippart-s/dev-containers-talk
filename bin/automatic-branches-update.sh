#!/bin/bash

for i in $(seq -w 0 11); do
  git switch step-$i
  git restore --source=main README.md
  git add README.md
  git commit -m "Sync fichier depuis main"
  git push
done