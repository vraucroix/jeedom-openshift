#!/bin/bash
echo 'Start init'

echo 'Start atd'
service atd start


echo 'Starting mysql'
service mysql start

if ! [ -f /.jeedom_backup_restore ]; then
	if [ ! -z "${RESTOREBACKUP}" ] && [ "${RESTOREBACKUP}" != 'NO' ]; then
		echo 'Need restore backup '${RESTOREBACKUP}
		wget ${RESTOREBACKUP} -O /tmp/backup.tar.gz
		php /var/www/html/install/restore.php backup=/tmp/backup.tar.gz
		rm /tmp/backup.tar.gz
		touch /.jeedom_backup_restore
		if [ ! -z "${UPDATEJEEDOM}" ] && [ "${UPDATEJEEDOM}" != 'NO' ]; then
			echo 'Need update jeedom'
			php /var/www/html/install/update.php
		fi
	fi
fi

echo 'All init complete'
chmod 777 /dev/tty*
chmod 777 -R /tmp
chmod 755 -R /var/www/html
chown -R www-data:www-data /var/www/html

echo 'Verify .dockerinit to recognize docker installation for jeedom'
if ! [ -f /.dockerinit ]; then
        touch /.dockerinit
        chmod 755 /.dockerinit
fi

echo 'Remove /tmp/jeedom/started file'
rm -f /tmp/jeedom/started

echo 'Start apache2'
service apache2 start

echo 'Start cron'
cron -f
