######## Configuración del proxy/balanceador ############
sudo apt update -y
sudo hostnamectl set-hostname Balanceador-VictorG
sudo apt install apache2 -y
###########################################
##### Habilitar mods y sitios #############
###########################################

sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod proxy_balancer
sudo a2enmod lbmethod_byrequests
sudo a2enmod ssl
sudo a2enmod rewrite
sudo a2dissite 000-default.conf

#######################################
######Importar la conf del sitio#######
#######################################

sudo tee /etc/apache2/sites-available/load-balancer.conf > /dev/null <<EOF
# Redirección HTTP a HTTPS
<VirtualHost *:80>
    ServerName wordpressvg.ddns.net
    ErrorLog /error.log
    CustomLog /access.log combined
    #Permite redirigir todo el tráfico de http a https, para que certbot no de problemas al crear el certificado
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
</VirtualHost>

# Configuración HTTPS
<IfModule mod_ssl.c>
    <VirtualHost *:443>
    	# Habilitar el ssl
        SSLEngine on
        ServerName wordpressvg.ddns.net
        
        # Certificados SSL (no válidos por ahora)
        SSLCertificateFile /etc/ssl/certs/ssl-cert-snakeoil.pem
        SSLCertificateKeyFile /etc/ssl/certs/ssl-cert-snakeoil.pem
        Include /etc/letsencrypt/options-ssl-apache.conf
        
        # Archivos de registro
        ErrorLog /error.log
        CustomLog /access.log combined
        
        # Configuración del Proxy Balancer
        <Proxy balancer://balanceador>
            #Server 1   
                BalancerMember http://192.168.10.68
            #Server 2
                BalancerMember http://192.168.10.69
        </Proxy>
        ProxyPass "/" "balancer://balanceador/"
        ProxyPassReverse "/" "balancer://balanceador/"
        ProxyPreserveHost On
        
        #Añadir las cabeceras de HTTPS para que Wordpress interprete correctamente el tipo de conexión
        RequestHeader set X-Forwarded-Proto "https" env=HTTPS
        RequestHeader set X-Forwarded-Host "wordpressvg.ddns.net"
   </VirtualHost>
</IfModule>
EOF
############################
############################

# Habilitar el balanceador
sudo a2ensite load-balancer.conf
sudo systemctl restart apache2

# Instalación certobot para obtener el certificado
sudo apt install certbot python3-certbot-apache -y

### Este comando de certbot, nos creará solo los certificados de manera no interactiva ####
sudo certbot certonly \
    --apache \
    -d wordpressvg.ddns.net \
    --email vgarciac34@iesalbarregas.es \
    --agree-tos \
    --non-interactive \
    --redirect
####

#### Ahora remplazaremos los certificados predefinidos por los de letsencrypt #####

sudo sed -i 's|SSLCertificateFile .*|SSLCertificateFile /etc/letsencrypt/live/wordpressvg.ddns.net/fullchain.pem|' /etc/apache2/sites-available/load-balancer.conf

sudo sed -i 's|SSLCertificateKeyFile .*|SSLCertificateKeyFile /etc/letsencrypt/live/wordpressvg.ddns.net/privkey.pem|' /etc/apache2/sites-available/load-balancer.conf

#####






