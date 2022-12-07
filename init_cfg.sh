#!/usr/bin/env bash

# profile bashrc settting
echo 'alias vi=vim' >> /etc/profile
echo "sudo su -" >> .bashrc

# Letting iptables see bridged traffic
modprobe br_netfilter
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

# local dns setting
echo "192.168.56.10 k8s-m" >> /etc/hosts
for (( i=1; i<=$1; i++  )); do echo "192.168.56.10$i k8s-w$i" >> /etc/hosts; done

# apparmor disable
systemctl stop apparmor && systemctl disable apparmor

# docker install
curl -fsSL https://get.docker.com | sh

# Cgroup Driver systemd
cat <<EOF | tee /etc/docker/daemon.json
{"exec-opts": ["native.cgroupdriver=systemd"]}
EOF
systemctl daemon-reload && systemctl restart docker

# package install
apt-get install bridge-utils net-tools jq tree wireguard -y

# swap off
swapoff -a

# Installing kubeadm kubelet and kubectl - v1.21.4
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
#apt-get install -y kubelet kubeadm kubectl
apt-get install -y kubelet=1.21.4-00 kubectl=1.21.4-00 kubeadm=1.21.4-00
apt-mark hold kubelet kubeadm kubectl
systemctl enable kubelet && systemctl start kubelet