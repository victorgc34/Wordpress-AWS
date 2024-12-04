#######Configuración del servidor de NFS #############
sudo apt update
sudo hostnamectl set-hostname Server-NFS-VictorG

#######Intalación y configuración del NFS-server#######
sudo apt install nfs-kernel-server -y
sudo mkdir -p /var/nfs/wordpress

#Indica que la carpeta no pertenece a nadie
sudo chown -R nobody:nogroup /var/www/nfs

# Configuración que le indica al servidor de nfs la carpeta y otros parámentros a compartir
sudo echo "/var/nfs               192.168.10.64/26(rw,sync,no_root_squash,no_subtree_check)" > /etc/exports
sudo systemctl restart nfs-kernel-server

# Descarga de Wordpress dentro de la carpeta compartida
sudo apt install unzip -y
sudo wget https://wordpress.org/latest.zip /var/www/nfs/
sudo unzip /var/nfs/latest.zip

# Permisos necesarios
sudo chmod -R 755 /var/www/nfs
sudo chown -R nobody:nogroup /var/www/nfs

###############################################################################################
#####No ejecutar las siguientes lineas hasta que se haya hecho la instalación del Wordpress####
###############################################################################################
sudo tee -a /var/nfs/wordpress/wp-config.php > /dev/null << 'EOF'
// Esto define el nombre de dominio para que WordPress lo interprete bien
define('WP_HOME', 'https://wordpressvg.ddns.net');
define('WP_SITEURL', 'https://wordpressvg.ddns.net');

// Esto permite que WordPress interprete las cabeceras del proxy, evitando problemas de comunicación entre el servidor web y el proxy/balanceador
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
    $_SERVER['HTTPS'] = 'on';
}
if (isset($_SERVER['HTTP_X_FORWARDED_HOST'])) {
    $_SERVER['HTTP_HOST'] = $_SERVER['HTTP_X_FORWARDED_HOST'];
}
EOF

