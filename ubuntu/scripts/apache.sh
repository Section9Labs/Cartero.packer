echo "Installing Apache"
apt-get -y install apache2

echo "Setting up some modules for Cartero in Apache"

a2enmod proxy
a2enmod proxy_http
a2enmod proxy_ajp
a2enmod rewrite
a2enmod deflate
a2enmod headers
a2enmod proxy_balancer
a2enmod proxy_connect
a2enmod proxy_html
