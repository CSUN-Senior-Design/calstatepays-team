#!/bin/bash
set -eu -o pipefail
sudo yum install httpd -y
sudo service httpd restart
echo “hello from $instanceid” | sudo tee  /var/www/html/index.html  > /dev/null
service httpd start
sudo yum repolist all
sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum install stress -y