#!/bin/bash
set -e
SALT='absolutlynotsafesaltvalue'
if [ -f /etc/container_environment/WALLABAG_SALT ] ; then
    	SALT=`cat /etc/container_environment/WALLABAG_SALT`
	# only copy default-cfg if SALT is given in environment
	cfgfile=/var/www/wallabag/inc/poche/config.inc.php
	if [ ! -f $cfgfile ]
	then
		cp /var/www/wallabag/inc/poche/config.inc.default.php $cfgfile &&
		chown www-data:www-data $cfgfile &&
		chmod 755 $cfgfile 
	fi

	for f in $cfgfile
	do
		# replace (empty) salt
		[ -f $f ] && sed -i "s/'SALT', '.*'/'SALT', '$SALT'/" $f
	done
fi
