#<MARIA-DB>
sudo su
apk add mariadb mariadb-client nano

DB_DATA_PATH="/var/lib/mysql"
DB_ROOT_PASS="kong"
DB_USER="kong"
DB_PASS="kong"
MAX_ALLOWED_PACKET="200M"

mysql_install_db --user=mysql --datadir=${DB_DATA_PATH}
rc-service mariadb start
mysqladmin -u root password "${DB_ROOT_PASS}"

echo "GRANT ALL ON *.* TO ${DB_USER}@'127.0.0.1' IDENTIFIED BY '${DB_PASS}' WITH GRANT OPTION;" > /tmp/sql
echo "GRANT ALL ON *.* TO ${DB_USER}@'localhost' IDENTIFIED BY '${DB_PASS}' WITH GRANT OPTION;" >> /tmp/sql
echo "GRANT ALL ON *.* TO ${DB_USER}@'::1' IDENTIFIED BY '${DB_PASS}' WITH GRANT OPTION;" >> /tmp/sql
echo "DELETE FROM mysql.user WHERE User='';" >> /tmp/sql
echo "DROP DATABASE test;" >> /tmp/sql
echo "FLUSH PRIVILEGES;" >> /tmp/sql
cat /tmp/sql | mysql -u root --password="${DB_ROOT_PASS}"
rm /tmp/sql

sed -i "s|max_allowed_packet\s*=\s*1M|max_allowed_packet = ${MAX_ALLOWED_PACKET}|g" /etc/mysql/my.cnf
sed -i "s|max_allowed_packet\s*=\s*16M|max_allowed_packet = ${MAX_ALLOWED_PACKET}|g" /etc/mysql/my.cnf

rc-update add mariadb default

#</MARIADB>

#<SAMPLE DATA SET>
sleep 10
wget https://downloads.mysql.com/docs/sakila-db.tar.gz
tar zxvf sakila-db.tar.gz
cd sakila-db
mysql -u root -pkong < sakila-schema.sql
mysql -u root -pkong < sakila-data.sql
#</SAMPLE DATA SET>

#Configure and setup micro-service
sudo apk add python3
sudo pip3 install flask pymysql
cp /opt/micro-dvd/micro-dvd.service /etc/init.d/
#ensure it starts on boot
mkdir /run/micro-dvd/
touch /run/micro-dvd/micro-dvd.pid
rc-update add micro-dvd.service default
sleep 5
echo "Starting Micro Services"
rc-service micro-dvd.service start
ps aux | grep python
