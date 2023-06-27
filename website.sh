#!/bin/bash
sudo su
yum update -y
yum install httpd -y
echo "<html><body><center><h1>Hello World</h1>
</center></html>" > /var/www/html/index.html
systemctl enable httpd
systemctl start httpd