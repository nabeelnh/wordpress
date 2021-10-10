#!/bin/bash

yum update -y
yum install httpd php php-mysql amazon-efs-utils mysql -y

# Enable AllowOverride All in httpd.conf
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd-backup.conf
sed -i '151s/AllowOverride None/AllowOverride All/g' /etc/httpd/conf/httpd.conf

# Mount EFS Volume on /var/www/html
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_dns_name}:/ /var/www/html
echo '${efs_dns_name}:/ /var/www/html nfs4 defaults,vers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 0 0' >> /etc/fstab

# Install Wordpress using WP-CLI
cd /var/www/html/
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
mysql -u ${DB_USER} -p ${DB_PASSWORD} -h ${DB_HOST} -e "create database ${DB_NAME}";
wp core download
wp core config --dbname=${DB_NAME} --dbuser=${DB_USER} --dbpass=${DB_PASSWORD} --dbhost=${DB_HOST}
wp core install --url="${alb_dns_name}" --title="${WP_TITLE}" --admin_user=${WP_USER} --admin_password=${WP_PASS} --admin_email=${WP_EMAIL}
chmod -R 755 wp-content
chown -R apache:apache wp-content

# Testing
echo "${efs_dns_name}
${alb_dns_name}
${s3_bucket_static_name}            
${DB_NAME}
${DB_USER}
${DB_PASSWORD}
${DB_HOST}
${WP_TITLE}
${WP_USER}
${WP_PASS}
${WP_EMAIL}" > ~/testing

# Append to wp-config.php
cat <<EOF >> /var/www/html/wp-config.php
define('WP_HOME', '/');
define('WP_SITEURL', '/');
EOF


# Start httpd
service httpd start
chkconfig httpd on

# Sync /var/www/html/wp-content/uploads to S3
cat <<EOF > /root/s3sync.sh
cd /var/www/html/wp-content/
aws s3 sync uploads s3://${s3_bucket_static_name}/wp-content/uploads/ --delete
EOF

chmod +x /root/s3sync.sh
/root/s3sync.sh

cat <<EOF >> /etc/crontab
*/5 * * * * root /root/s3sync.sh
EOF
