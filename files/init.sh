#!/bin/bash

set -x 

chown -R "1001:100" /workspace
chown -R "1001:100" /nix

# create a script to install nix
echo "export HOME=/workspace" > /workspace/install-nix.sh
echo "wget -O /workspace/install.sh  https://nixos.org/nix/install" >> /workspace/install-nix.sh 

echo "sh /workspace/install.sh --no-daemon" >> /workspace/install-nix.sh
echo ". ~/.nix-profile/etc/profile.d/nix.sh" >> /workspace/install-nix.sh

echo 'export PATH="/workspace/.nix-profile/bin:$PATH"' >> /workspace/install-nix.sh


sudo -u jovyan sh /workspace/install-nix.sh


export DEVBOX_USE_VERSION=$DEVBOX_USE_VERSION
wget --quiet --output-document=/dev/stdout https://get.jetify.com/devbox   | bash -s -- -f
chown -R 1001:100 /usr/local/bin/devbox
mkdir -p /workspace/.local/bin
cp /usr/local/bin/devbox /workspace/.local/bin/devbox
chown -R 1001:100 /workspace/.local/bin/devbox
chmod +x /workspace/.local/bin/devbox

mkdir -p /workspace/User/
echo '{"workbench.colorTheme": "Visual Studio Dark"}' > /workspace/User/settings.json
chown -R 1001:100 /workspace/User

export PATH="$HOME/.nix-profile/bin:$PATH"

export AWS_DEFAULT_REGION="us-east-1"

export AWS_ACCESS_KEY_ID="test"

export AWS_SECRET_ACCESS_KEY="test"

#aws s3 mb s3://results --endpoint-url=http://eoap-quickwin-localstack:4566