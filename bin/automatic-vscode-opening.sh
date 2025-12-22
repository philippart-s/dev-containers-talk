#!/bin/bash

for i in $(seq -w 0 11); do
   code ../../dev-containers-talk-step-$i/
done

code ../../dev-containers-template-talk
code ../../feature-slidesk-talk