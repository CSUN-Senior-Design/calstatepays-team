#!/bin/bash
set -eu -o pipefail
sudo yum install httpd -y
sudo service httpd restart
echo “hello from $(curl http://169.254.169.254/latest/meta-data/instance-id)” | sudo tee  /var/www/html/index.html  > /dev/null
service httpd start
sudo yum repolist all
sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum install stress -y