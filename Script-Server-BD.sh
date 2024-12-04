################ Configuración del servidor de base de datos ################
sudo apt update
sudo hostnamectl set-hostname Server-Basededatos-VictorG
sudo apt install mysql-server -y

##Modificar configuración para que MySQL permita conexiones externas
sudo sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql

######################
#Parámetros database:#
######################
#####!!!!!!Importante¡¡¡¡¡¡¡¡¡#####
#$IP_MAS=rango de IPs de los servidores Web (no poner máscara de red ya que mysql no lo permite)
#$db_passwd=contraseña_usuario_root_database
#$DB_USER=es el usuario utilizado para la base de datos Wordpress
#$DB_PASS=contraseña del usuario para la base de datos Wordpress

DB_USER=user_wordpress
DB_PASS=GHHJHSGDY

IP_MAS=192.168.10.%
db_passwd=1234-Admin
#######################
#######################

#Crea la base de datos para Wordpress (El nombre de la base de datos es wordpress_db)
sudo mysql -u root -p$db_passwd -e "CREATE DATABASE wordpress_db;FLUSH PRIVILEGES;"

# Añadir una contraseña al usuario root de la base de datos
sudo mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY '$db_passwd';"

# Creación de un nuevo usuario de MySQL y asignación de privilegios
sudo mysql -u root -p$db_passwd -e "CREATE USER '$DB_USER'@'$IP_MAS' IDENTIFIED BY '$DB_PASS';"
sudo mysql -u root -p$db_passwd -e "GRANT ALL PRIVILEGES ON wordpress_db.* TO '$DB_USER'@'$IP_MAS';FLUSH PRIVILEGES;"

##Modificar configuración para que MySQL permita conexiones externas
sudo sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql

#Para que la base de datos no tarde en responder al quitarle la conexión a internet
#Medida aplicada ya que al impedir la conexión a internet, la base de datos intenta resolver algunos nombres de dominio, lo que causa un retraso importante en la resolución de peticiones
sudo echo "skip-name-resolve" >> /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql

