#!/bin/bash

## ☁️ ovhcloud CLI installation
### ⬇️ Get ovhcloud CLI for Linux ARM64
wget https://github.com/ovh/ovhcloud-cli/releases/download/v0.11.0/ovhcloud-cli_Linux_arm64.tar.gz -O /tmp/ovhcloud-cli.tar.gz

### 🔨 Extract and install ovhcloud CLI
cd /tmp
tar -xzf ovhcloud-cli.tar.gz
sudo cp ovhcloud /usr/bin/ovhcloud
sudo chmod +x /usr/bin/ovhcloud
sudo chown vscode:vscode /usr/bin/ovhcloud