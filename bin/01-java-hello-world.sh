#!/bin/bash

# 🛠️ Load environment variables 🛠️
source ./00-source-env.sh

clear

# 👋 First Hello, World!!!
echo "javac ../scripts/HelloWorld.java"
echo "java ../scripts/HelloWorld.java"

javac ../scripts/HelloWorld.java
java ../scripts/HelloWorld.java