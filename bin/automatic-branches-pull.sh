#!/bin/bash

for i in $(seq -w 0 11); do
  git switch step-$i
  git pull
done