#!/bin/bash

# Update package list and upgrade all packages
apt-get update && apt-get upgrade -y

# Install Apache web server
apt-get install apache2 -y

# Enable mod_security and mod_ssl
a2enmod security2 ssl

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
" > /etc/apache2/sites-available/default-ssl.conf

a2ensite default-ssl

# Configure mod_security
mv /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf

# Configure mod_security rules
wget https://raw.githubusercontent.com/SpiderLabs/owasp-modsecurity-crs/v3.3/master/crs-setup.conf.example -O /etc/modsecurity/crs-setup.conf
wget https://raw.githubusercontent.com/SpiderLabs/owasp-modsecurity-crs/v3.3/master/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example -O /etc/modsecurity/owasp-crs/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
wget https://raw.githubusercontent.com/SpiderLabs/owasp-modsecurity-crs/v3.3/master/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf.example -O /etc/modsecurity/owasp-crs/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf

# Test Apache configuration and reload service
apachectl configtest && service apache2 reload
