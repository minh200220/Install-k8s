#Install kubelet, kubeadm and kubectl
sudo apt -y install curl apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt -y install vim git curl wget kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

#Disable Swap
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a

#Set hostname 
#nano /etc/hostname

#Set hosts
#nano /etc/hosts
#127.0.0.1 localhost 
#ip.address master
#ip.address worker1
#ip.address worker2

#Configure sysctl
sudo modprobe overlay
sudo modprobe br_netfilter
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

#Install Container runtime
sudo apt update
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y containerd.io docker-ce docker-ce-cli

# Create required directories
sudo mkdir -p /etc/systemd/system/docker.service.d

# Create daemon json config file
sudo tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
#config proxy for docker
sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf <<EOF
[Service]
Environment="http_proxy=http://proxy.ctu.edu.vn:3128"
Environment="https_proxy=http://proxy.ctu.edu.vn:3128"
Environment="ftp_proxy=http://proxy.ctu.edu.vn:3128"
Environment="no_proxy=localhost,127.0.0.1,192.168.0/16,10.96.0.0/16"
Environment="HTTP_PROXY=http://proxy.ctu.edu.vn:3128"
Environment="HTTPS_PROXY=http://proxy.ctu.edu.vn:3128"
Environment="FTP_PROXY=http://proxy.ctu.edu.vn:3128"
Environment="NO_PROXY=localhost,127.0.0.1,192.168.0/16,10.96.0.0/16"
EOF

#Start and enable Services
sudo systemctl daemon-reload 
sudo systemctl restart docker
sudo systemctl enable docker

#Enable kubelet service
sudo systemctl enable kubelet
#Pull container images
sudo kubeadm config images pull
#Create cluster change apiserver-advertise-address
sudo kubeadm init --apiserver-advertise-address=192.168.100.16 --pod-network-cidr=10.244.0.0/16 
#Configure kubectl 
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
#Install network plugin on Master
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
