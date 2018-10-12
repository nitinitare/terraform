#!bin/bash
sudo apt-get install git
sudo git clone https://github.com/markshead/chef-solo-demo.git /var/chef
sudo true && curl -L https://www.opscode.com/chef/install.sh | sudo bash
chef-solo -v
