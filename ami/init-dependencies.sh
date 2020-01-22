#!/bin/bash

sudo apt-get update -y
sudo apt-get install apt-transport-https jq software-properties-common -y

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y
sudo apt-get -y install docker-ce
sudo usermod -G docker -a ubuntu

# Install RKE
wget https://github.com/rancher/rke/releases/download/v1.0.2/rke_linux-amd64

chmod +x rke_linux-amd64
sudo mv rke_linux-amd64 /usr/bin/rke

# Install Helm 3
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
