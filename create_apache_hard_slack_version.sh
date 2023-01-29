#!/bin/bash

# Update package list and upgrade all packages
upgradepkg --install-new /var/log/packages/*

# Install Apache web server
installpkg apache

# Enable mod_security and mod_ssl
# Slackware don't have mod_security and mod_ssl by default, you need to download it from the Apache website, extract it and put the modules in the apache2 modules folder.

# Create a self-signed SSL certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt

# Configure Apache to use the self-signed SSL certificate
echo "
<VirtualHost _default_:443>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
        SSLEngine on
        SSLCertificateFile      /etc/ssl/certs/apache-selfsigned.crt
        SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
        <FilesMatch \"\.(cgi|shtml|phtml|php)$\">
                                SSLOptions +StdEnvVars
        </FilesMatch>
        <Directory /usr/lib/cgi-bin>
                                SSLOptions +StdEnvVars
        </Directory>
        BrowserMatch \"MSIE [2-6]\" \
                               nokeepalive ssl-unclean-shutdown \
                               downgrade-1.0 force-response-1.0
        BrowserMatch \"MSIE [17-9]\" ssl-unclean-shutdown
</VirtualHost>
" > /etc/httpd/httpd.conf

# Configure mod_security
# Slackware don't have mod_security by default, you need to download it from the Apache website, extract it and put the modules in the apache2 modules folder.

# Test Apache configuration and reload service
httpd -t && apachectl restart
