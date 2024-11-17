#!/bin/bash
set -e

# install git, azure cli, terraform, docker
sudo apt-get update
sudo apt-get install -y git-all
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update
sudo apt-get install -y terraform

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

rm -rf azure_devops_agent
mkdir -p azure_devops_agent
cd  azure_devops_agent
wget "https://vstsagentpackage.azureedge.net/agent/3.243.0/vsts-agent-linux-x64-3.243.0.tar.gz"
tar zxvf vsts-agent-linux-x64-3.243.0.tar.gz
# https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/linux-agent?view=azure-devops
./config.sh --acceptTeeEula --unattended --url $1 --auth pat --token $2
screen -S agentsession bash ./run.sh
