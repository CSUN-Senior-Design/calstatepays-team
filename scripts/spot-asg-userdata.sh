#!/bin/bash
set -eu -o pipefail
sudo yum install httpd -y
sudo service httpd restart
echo “hello world from $instanceid” > /var/www/html/index.html
service httpd start
sudo yum repolist all
sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum install stress -y