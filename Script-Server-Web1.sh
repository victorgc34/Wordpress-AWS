######### Configuración del Server-Web-1 #############

sudo apt update -y
sudo hostnamectl set-hostname Server-Web-1-VictorG
sudo apt install apache2 -y

# Desabilitar el sitio por defecto
sudo a2dissite 000-default.conf

#Habilita el modulo necesario
sudo a2enmod rewrite
sudo systemctl restart apache2

#Añade los repositorio de php
sudo add-apt-repository -y ppa:ondrej/php
sudo apt update -y

#Instalación de php y dependencias para apache y mysql
sudo apt install php libapache2-mod-php php-mysql php-curl php-gd php-xml php-mbstring php-xmlrpc php-zip php-soap php-intl -y

#Modifica a la versión de php8.3
sudo update-alternatives --set php /usr/bin/php8.3

#Instalación de cliente nfs
sudo apt install nfs-common -y
sudo mkdir /var/www/nfs/

#Automatización de montaje de la carpeta compartida
sudo echo "192.168.10.71:/var/nfs    /var/www/nfs   nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" >> /etc/fstab

#Añade la configuración del sitio a apache
sudo tee /etc/apache2/sites-available/proyecto.conf > /dev/null <<EOF                                                    
<VirtualHost *:80>
    #ServerAdmin webmaster@localhost
    DocumentRoot /var/www/nfs/wordpress
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
    <Directory /var/www/nfs/wordpress>
        Options FollowSymlinks
        AllowOverride All
        Require all granted
    </Directory>
    SetEnvIf X-Forwarded-Proto "https" HTTPS=on
</VirtualHost>
EOF

#Habilita el sitio de apache
sudo a2ensite proyecto.conf
sudo systemctl reload apache2




