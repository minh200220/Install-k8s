sudo cat /etc/environment <<EOF
export http_proxy=http://proxy.ctu.edu.vn:3128
export https_proxy=http://proxy.ctu.edu.vn:3128
export ftp_proxy=http://proxy.ctu.edu.vn:3128
export no_proxy=localhost,127.0.0.0/16,192.168.100.0/16,10.96.0.0/16
export HTTP_PROXY=http://proxy.ctu.edu.vn:3128
export HTTPS_PROXY=http://proxy.ctu.edu.vn:3128
export FTP_PROXY=http://proxy.ctu.edu.vn:3128
export NO_PROXY=localhost,127.0.0.0/16,192.168.100.0/16,10.96.0.0/16
EOF

ssh-keygen
cat   .ssh/id_rsa.pub  > .ssh/authorized_keys
echo 'StrictHostKeyChecking no' >>  .ssh/config

#B2: Copy thư mục .ssh den tat ca cac node tính toán
scp -r .ssh/  k8s-master:~/
scp -r .ssh/  k8s-slave02:~/
scp -r .ssh/  k8s-slave01:~/





