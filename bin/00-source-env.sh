#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# ⚒️ Source environment variables ⚒️
set -a
source ../.env
set +a