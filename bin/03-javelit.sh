#!/bin/bash

# 🛠️ Load environment variables 🛠️
source ./00-source-env.sh

clear

bat -P -r 13: $(basename "$0")

echo ""
read -n 1 -p "Press a key"

# 🚡 Run Javelit demo
javelit hello