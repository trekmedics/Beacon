Deployment Instructions

Created by Mickey Cowden, last modified on Mar 31, 2015 Go to start of metadata

Create AWS Instance
===================
Log into https://console.aws.amazon.com/
Select EC2
Select Launch Instance
Select Amazon Machine Image (AMI) (Recommend:  Ubuntu Server 14.04 LTS (HVM), SSD Volume Type)
Select Instance Type (Recommend:  At least t2.medium)
  Pricing:  http://aws.amazon.com/ec2/pricing/
Select "Edit security groups"
  Add Rules
  SSH (should already be a rule)
  HTTP
  HTTPS
  Click "Review and Launch"
Click "Edit storage"
  Edit size of volume (Recommend:  30GB)
  Click "Review and Launch"
Click "Launch"
Select "Create a new key pair"
Name the key pair
Click Launch (it will likely take a couple minutes for the instance to start up)
From the instance list:
  You can name the instance.
  Observe the Public IP address.

To change Instance Type:
Using the AWS Management Console
  Go to "Volumes" and create a Snapshot of your instance's volume.
  Go to "Snapshots" and select "Create Image from Snapshot".
  Go to "AMIs" and select "Launch Instance" and choose your "Instance Type" etc.

Configure AWS Instance
======================
SSH to instance
  ssh -i <beacon_key.pem> ubuntu@<ip_address>
#  ssh -i ../BeaconProduction.pem.txt ubuntu@52.4.54.131
  ssh -i ../BeaconProduction.pem.txt ubuntu@52.4.133.252
Configure /etc/hosts
Run these commands:
hostname
sudo vim /etc/hosts
On the second line (below "127.0.0.1 localhost") put:
  127.0.1.1 <hostname>
  where <hostname> is the output from running the above hostname command
This should stop the error message "sudo: unable to resolve host ip-xxx.xx.xx.xxx" from showing up.
Restart the instance:  sudo reboot

Reboot AWS Instance
====================
From ssh terminal connection:
-----------------------------
sudo reboot

From AWS Console (better):
--------------------------
Log into https://console.aws.amazon.com/
Select EC2
...

Note:
Reboot just kills and restarts all processes on instance. IP and disk storage all continue as before.
Restart Instance, stops instance (and charging), and results in a new IP when restarted.

Bash Commands
=============
Note:  The "exec $SHELL" commands will stop the script if these commands are run as a script.  Recommend running each command individually.

Update and Install Required Dependencies
========================================
sudo apt-get update
sudo apt-get -y upgrade
  If asked about a new version of /boot/grub/menu.lst select "install the package maintainer's version"
sudo apt-get -y dist-upgrade
sudo apt-get -y install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev git gcc make libffi-dev nodejs libsqlite3-dev tcl nginx sqlite3

Install Redis
=============
cd
mkdir temp
cd temp/
wget http://download.redis.io/releases/redis-2.8.19.tar.gz
tar -xzf redis-2.8.19.tar.gz
cd redis-2.8.19/
make
make test
sudo cp src/redis-server /usr/local/bin/
sudo cp src/redis-cli /usr/local/bin/
sudo mkdir /etc/redis
sudo mkdir /var/redis
sudo cp utils/redis_init_script /etc/init.d/redis_6379
sudo cp redis.conf /etc/redis/6379.conf
sudo mkdir /var/redis/6379
sudo vim /etc/redis/6379.conf
  Set "daemonize" to yes
  Set the pidfile to /var/run/redis_6379.pid
  Set the logfile to /var/log/redis_6379.log
  Set the dir to /var/redis/6379
  Save and exit
sudo update-rc.d redis_6379 defaults
sudo service redis_6379 start

Install Ruby
============
cd
echo 'gem: --no-document' >> ~/.gemrc
git clone git://github.com/sstephenson/rbenv.git .rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
exec $SHELL
git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
exec $SHELL
rbenv install 2.2.0
rbenv global 2.2.0
ruby -v
gem update --system
gem update
gem install bundler

Generate Key for Bitbucket
==========================
ssh-keygen   # accept default values during on-screen instructions
ssh-agent /bin/bash
ssh-add ~/.ssh/id_rsa
ssh-add -l
cat ~/.ssh/id_rsa.pub

Configure Bitbucket with Key
============================
Go to https://bitbucket.org/
Select the Beacon repository
Click the Settings icon
Click "Deployment keys"
Click "Add key"
For the Label, put "Beacon - Production"
Paste the key from the previous section into the Key field
Click "Add key"

Install Beacon
==============
Set Rails Environment
---------------------
vim ~/.bashrc
  Put this at the bottom of the file:
    export RAILS_ENV=production
exec $SHELL

Get Source Code
---------------
cd
git clone git@bitbucket.org:trekmedics/beacon-v.2.git Beacon
cd Beacon/
bundle

Set Up Beacon Environment Variables
-----------------------------------
cd ~/Beacon
bundle exec rake secret
vim ~/.bashrc
  export BEACON_SECRET_KEY_BASE=<secret_key>
  export BEACON_TWILIO_ACCOUNT_SID=<twilio_account_sid>
  export BEACON_TWILIO_AUTH_TOKEN=<twilio_auth_token>
exec $SHELL
bundle exec rake db:setup

Set Up Bongo Environment Variables
-----------------------------------
cd ~/Beacon
bundle exec rake secret
vim ~/.bashrc
  export BEACON_BONGO_USER_NAME=<user_name>
  export BEACON_BONGO_PASSWORD=<password>
  export BEACON_BONGO_API_KEY=<api_key>
  export BEACON_BONGO_SENDER_NAME=<sender_name>
exec $SHELL
bundle exec rake db:setup

Configure Web Socket Location
-----------------------------
cd
vim Beacon/app/assets/javascripts/angular-app/app.js.coffee
# Make sure that the "websocket_url" is equal to "dispatch.trekmedics.org/websocket", for example:
websocket_url: 'beacon.trekmedics.org/websocket'

Beacon Start-up Script
======================
Recommend using "screen" to run Beacon in.
cd ~/Beacon
screen
bundle exec rake assets:precompile    # only necessary if assets have been updated
bundle exec rake websocket_rails:stop_server
bundle exec rake websocket_rails:start_server
bundle exec foreman start
<Ctrl>-a d

SSL Certificate
===============
https://www.openssl.org/docs/HOWTO/keys.txt
https://www.openssl.org/docs/HOWTO/certificates.txt
cd
mkdir ssl
cd ssl/
openssl genrsa -out privkey.pem 2048                  # creates key
openssl req -new -key privkey.pem -out cert.csr   # creates CSR, follow on-screen instructions
  Note Common Name means the fully qualified domain name (i.e. beacon.trekmedics.org)

Submit CSR to Certificate Authority
===================================
Example:  https://www.namecheap.com/security/ssl-certificates/domain-validation.aspx
  Namecheap has a $9.00 per year option for SSL certificates.
  May require creating a certificate bundle (https://support.comodo.com/index.php?/Knowledgebase/Article/View/643/0/how-do-i-make-my-own-bundle-file-from-crt-files)
CA will issue your SSL certificate.
Copy this certificate over to the AWS instance.

Install SSL Certificate
=======================
cd
mkdir ssl
cd ssl
# Copy all certificates (including intermediate certificates) and private key to ~/ssl on the AWS instance.
cat dispatch_trekmedics_org.crt COMODORSADomainValidationSecureServerCA.crt COMODORSAAddTrustCA.crt AddTrustExternalCARoot.crt > dispatch_ssl_bundle.crt
sudo mkdir /etc/nginx/ssl
sudo mv ~/ssl/privkey.pem /etc/nginx/ssl/
sudo mv ~/ssl/dispatch_ssl_bundle.crt /etc/nginx/ssl/
cd /etc/nginx/ssl/
sudo chmod 400 privkey.pem
sudo chown root:root *

Configure Nginx
===============
cd /etc/nginx/sites-available
sudo vim dispatch

Paste the following configuration
---------------------------------
  Note the SSL certificate and key need to be set (from previous section)
  Note the server name needs to be set (i.e. dispatch.trekmedics.org)
server {
  listen 80;
  server_name dispatch.trekmedics.org;
  return 301 https://$server_name$request_uri;
}
server {
  listen 443;
  server_name dispatch.trekmedics.org;
  ssl on;
  ssl_certificate /etc/nginx/ssl/beacon_ssl_bundle.crt;
  ssl_certificate_key /etc/nginx/ssl/privkey.pem;
  ssl_session_timeout 5m;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_ciphers "HIGH:!aNULL:!MD5 or HIGH:!aNULL:!MD5:!3DES";
  ssl_prefer_server_ciphers on;
  location / {
    proxy_pass http://localhost:5000;
  }
  location /websocket {
    proxy_pass http://localhost:3001;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
  }
}
sudo ln -s /etc/nginx/sites-available/dispatch /etc/nginx/sites-enabled/dispatch
sudo service nginx reload

Screen Instructions
===================
screen         # start screen
Ctrl + A, D   # detach screen
screen -r     # resume screen

Additional Requirements
=======================
Domain name points to public IP address provided by AWS.

Rebooting production
====================
To Reboot instance (preserves disk volume and IP. Stop and restart does not.)
From: http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-reboot.html
Reboot Your Instance

An instance reboot is equivalent to an operating system reboot. In most cases, it takes only a few minutes to reboot your instance. When you reboot an instance, it remains on the same physical host, so your instance keeps its public DNS name, private IP address, and any data on its instance store volumes.

Rebooting an instance doesn't start a new instance billing hour, unlike stopping and restarting your instance.

We might schedule your instance for a reboot for necessary maintenance, such as to apply updates that require a reboot. No action is required on your part; we recommend that you wait for the reboot to occur within its scheduled window. For more information, see Scheduled Events for Your Instances.

We recommend that you use Amazon EC2 to reboot your instance instead of running the operating system reboot command from your instance. If you use Amazon EC2 to reboot your instance, we perform a hard reboot if the instance does not cleanly shut down within four minutes. If you use AWS CloudTrail, then using Amazon EC2 to reboot your instance also creates an API record of when your instance was rebooted.

After a reboot, run update_beacon to restart the production server.

To reboot an instance using the console
---------------------------------------
Open the Amazon EC2 console.
In the navigation pane, click Instances.
Select the instance, click Actions, select Instance State, and then click Reboot.
Click Yes, Reboot when prompted for confirmation.

To reboot an instance using the command line
--------------------------------------------
You can use one of the following commands. For more information about these command line interfaces, see Accessing Amazon EC2.
reboot-instances (AWS CLI)
ec2-reboot-instances (Amazon EC2 CLI)
Restart-EC2Instance (AWS Tools for Windows PowerShell)



Postgresql
===========

To preserve data from one db to another
---------------------------------------
Add
gem 'yaml_db'
to Gemfile

run bundle install
then

bundle exec rake db:data:dump
or
bundle exec rake db:data:dump_dir
to save data

bundle exec rake db:data:load
or
bundle exec rake db:data:load_dir

to load data

Mac OS X instructions to start
------------------------------
brew install postgres
To have launchd start postgresql at login:
    ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents
Then to load postgresql now:
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
Or, if you don't want/need launchctl, you can just run:
    postgres -D /usr/local/var/postgres

initdb /usr/local/var/postgres

To use postgres with rails app
------------------------------
gem install pg -- --with-pg-config=/usr/local/bin/pg_config
bundle install

Now, set up your config/database.yml file to point to your Posgres database.
development:
  adapter: postgresql
  encoding: unicode
  database: beacon_dev
  pool: 5
  username: your_username_on_mac
  password:

test:
  adapter: postgresql
  encoding: unicode
  database: beacon_test
  pool: 5
  username: your_username_on_mac
  password:


Useful commands
===============
bundle exec rake tmp:cache:clear
bundle exec rake assets:clean

Nokogiri issues - OS X
======================
Problem:
Building nokogiri using system libraries.
libxml2 version 2.6.21 or later is required

From http://stackoverflow.com/questions/23668684/issue-installing-nokogiri-in-bundle-install

brew install libxml2
bundle config build.nokogiri "--use-system-libraries --with-xml2-include=/usr/local/opt/libxml2/include/libxml2"
bundle install

or

gem install nokogiri -- --use-system-libraries=true --with-xml2-include=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk/usr/include/libxml2

or

gem install nokogiri -- --with-xml2-include=/usr/local/opt/libxml2/include/libxml2

or for Yosemite
bundle config build.nokogiri --use-system-libraries --with-xml2-include=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk/usr/include/libxml2

bundle install

gem install nokogiri -- --use-system-libraries

To download production.log
==========================
scp -i ../BeaconProduction.pem.txt ubuntu@52.4.133.252:Beacon/log/production.log log/

libv8 issues on OS X
====================
gem install libv8 -- --with-system-v8


Generate documentation
======================
gem install rdoc
bundle install
bundle exec sdoc app
mv app/doc public/doc
scp -r -i ../BeaconProduction.pem.txt public/doc ubuntu@52.4.133.252:Beacon/public/
