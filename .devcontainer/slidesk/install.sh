#!/bin/sh
set -e

echo "Activating feature 'slidesk'"

## 🖼️ SliDesk installation
### ⬇️ Get SliDesk for Linux 
wget https://github.com/slidesk/slidesk/releases/download/2.14.9/slidesk_linux-${DISTRIBUTION}.tar.gz -O /tmp/slidesk.tar.gz

### 🔨 Extract and install SliDesk 
cd /tmp
tar -xzf slidesk.tar.gz
sudo cp slidesk_linux-arm /usr/bin/slidesk
sudo chmod +x /usr/bin/slidesk
sudo chown vscode:vscode /usr/bin/slidesk