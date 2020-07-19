#!/bin/bash
# https://kvz.io/blog/2013/11/21/bash-best-practices/
set -o errexit -o nounset -o pipefail -o xtrace
ADMIN_KEY="/vagrant/rob.pub" # >> CHANGE ME <<

if [ "$(id -u)" -ne 0 ]; then
  echo "must login as root user"
  exit 1
elif ! [ -f "$ADMIN_KEY" ]; then
  echo "invalid admin key: $ADMIN_KEY"
  exit 1
fi

### BEGIN ######################################################################
# Ensure default permissions are 755. Do not give special access to user-groups.
# TODO: This should be 750, but redmine plugins break when building as root.
# TODO: Configure NTP
perl -i.original \
  -pe 's/^(USERGROUPS_ENAB\s+)yes\s*$/\1no\n/;' \
  -pe 's/^(UMASK\s+)\d{3}$/\1 022\n/' \
  /etc/login.defs

apt-get update
apt-get -y upgrade

### WEB SERVER #################################################################
apt-get install -y apache2
mkdir -p /etc/systemd/system/apache2.service.d
cat <<"EOF" > /etc/systemd/system/apache2.service.d/override.conf
[Service]
Restart=always
EOF
a2ensite 000-default

### GITOLITE ###################################################################
apt-get install -y git
useradd --create-home --shell /bin/bash --user-group git
su - git <<EOF
echo 'export PATH="\$HOME/bin:\$PATH"' >> ~/.bashrc
git clone https://github.com/sitaramc/gitolite.git ~/gitolite
mkdir -p ~/bin
~/gitolite/install -ln ~/bin
~/bin/gitolite setup -pk "$ADMIN_KEY"
EOF
chmod -R 750 ~git/projects.list && chmod -R 750 ~git/repositories
perl -i.original -pe 's/(^\s*UMASK\s*=>\s*)\d{4}/\1 0027/' ~git/.gitolite.rc
# git clone ssh://git@localhost:2222/gitolite-admin.git

### GITWEB #####################################################################
apt-get install -y cgit
cat <<"EOF" >> /etc/cgitrc
project-list=/home/git/projects.list
scan-path=/home/git/repositories
EOF
usermod -aG git www-data
a2enmod cgi

### JENKINS ####################################################################
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
printf '\ndeb https://pkg.jenkins.io/debian-stable binary/\n' >> /etc/apt/sources.list
apt-get update && apt-get install -y jenkins
usermod -aG git jenkins

# TODO: Fix reverse proxy broken error
cat <<"EOF" >> /etc/apache2/conf-available/jenkins.conf
ProxyPass         /jenkins  http://127.0.0.1:8080/jenkins nocanon
ProxyPassReverse  /jenkins  http://127.0.0.1:8080/jenkins
ProxyRequests     Off
AllowEncodedSlashes NoDecode

# Local reverse proxy authorization override
# Most unix distribution deny proxy by default (ie /etc/apache2/mods-enabled/proxy.conf in Ubuntu)
<Proxy http://127.0.0.1:8080/jenkins*>
	Require all granted
</Proxy>
EOF

cat <<"EOF" >> /etc/default/jenkins
JENKINS_ARGS="$JENKINS_ARGS --prefix=$PREFIX --httpListenAddress=127.0.0.1"
EOF

a2enmod headers proxy proxy_http
a2enconf jenkins

### REDMINE ####################################################################
apt-get install -y libapache2-mod-passenger mysql-client mysql-server
apt-get install -y redmine redmine-mysql
apt-get install -y gcc g++ libsqlite3-dev libmysqlclient-dev make ruby-dev # for ruby extensions
systemctl stop apache2 jenkins && gem update # to decrease memory usage
gem install bundler
sed -i.original '/<\s*IfModule/a\ \ PassengerDefaultUser www-data' \
  /etc/apache2/mods-available/passenger.conf
ln -s /usr/share/redmine/public /var/www/html/redmine
touch /usr/share/redmine/Gemfile.lock
chown www-data:www-data /usr/share/redmine/Gemfile.lock

## Passenger (backup app server) ##
# TODO: Add check that redmine puma and passenger are not both enabled.
cat <<"EOF" >> /etc/apache2/conf-available/redmine_passenger.conf
<IfModule mod_passenger.c>
	RedirectMatch "^/$" "/redmine/"
	<Directory /var/www/html/redmine>
		RailsBaseURI /redmine
		PassengerResolveSymlinksInDocumentRoot on
	</Directory>
</IfModule>
<IfModule !mod_passenger.c>
	Error "mod_passenger is required by redmine_passenger."
</IfModule>
EOF
a2enconf redmine_passenger
a2enmod passenger
# https://stackoverflow.com/a/32030635
# https://emptyhammock.com/projects/info/pyweb/webconfig.html

# ## Puma (multithreaded app server) ##
# apt-get install -y gcc make ruby-dev
# echo 'gem "puma"' >> /usr/share/redmine/Gemfile.local
# # Execute in a subshell to return to this original directory
# (cd /usr/share/redmine && ./bin/bundle install --without test development rmagick)
# cat <<"EOF" > /etc/systemd/system/redmine_puma.service
# # https://github.com/puma/puma/blob/master/docs/systemd.md
# [Unit]
# Description=Redmine Puma
# After=network.target

# [Service]
# ExecStart=/usr/local/bin/puma --bind tcp://127.0.0.1:8081
# Restart=always
# Type=simple
# User=www-data
# WorkingDirectory=/usr/share/redmine
# # Helpful for debugging socket activation, etc.
# #Environment=PUMA_DEBUG=1

# [Install]
# WantedBy=multi-user.target
# EOF

# cat <<"EOF" >> /etc/apache2/conf-available/redmine_puma.conf
# # http://www.redmine.org/projects/redmine/wiki/HowTo_Install_Redmine_in_a_sub-URI
# ProxyPass         /redmine  http://127.0.0.1:8081/redmine
# ProxyPassReverse  /redmine  http://127.0.0.1:8081/redmine
# EOF
# a2enconf redmine_puma

# cat <<"EOF" >> /usr/share/redmine/config/environment.rb
# ActionController::Base.relative_url_root = "/redmine"
# EOF

## Auxiliary ##
apt-get install -y imagemagick
apt-get install -y postfix
cat <<"EOF" >> /etc/redmine/default/configuration.yml
production:
  email_delivery:
    delivery_method: :sendmail
EOF

### HEADER #####################################################################
a2enmod substitute
cat <<"EOF" >> /etc/apache2/apache2.conf
<Location "/">
	AddOutputFilterByType INFLATE;SUBSTITUTE;DEFLATE text/html text/plain text/xml
	Substitute "s|<\s*/\s*head\s*>|<script src=\"/inject_header.js\"></script></head>|i"
</Location>
EOF

# TODO: Add CSS
cat <<"EOF" >> /var/www/html/inject_header.js
document.addEventListener("DOMContentLoaded", function() {
  var header = document.createElement("div");
  header.style = "background-color:crimson;text-align:center;";

  function addLink(name) {
    var a = document.createElement("a");
    a.href = "/" + name;
    a.style = "color:white;margin:5px";
    a.appendChild(document.createTextNode(name));
    header.appendChild(a);
  }
  addLink("cgit");
  addLink("jenkins");
  addLink("redmine");

  document.body.insertBefore(header, document.body.firstChild);
});
EOF

### END ########################################################################
for app in apache2 jenkins; do
  systemctl enable $app && systemctl restart $app
done
