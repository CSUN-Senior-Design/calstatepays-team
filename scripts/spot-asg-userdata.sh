#!/bin/bash
set -eu -o pipefail
sudo yum install httpd -y
sudo service httpd restart
echo “hello from $(curl http://169.254.169.254/latest/meta-data/instance-id)” | sudo tee  /var/www/html/index.html  > /dev/null
sudo amazon-linux-extras install epel
sudo yum install stress -y
stress --cpu 1 --timeout 300