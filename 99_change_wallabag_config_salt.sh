#!/bin/bash
set -e
SALT='absolutlynotsafesaltvalue'
if [ -f /etc/container_environment/WALLABAG_SALT ] ; then
    SALT=`cat /etc/container_environment/WALLABAG_SALT`
fi
for f in /var/www/wallabag/inc/poche/config.inc.php /var/www/wallabag/inc/poche/config.inc.default.php
do
	[ -f $f ] && sed -i "s/'SALT', '.*'/'SALT', '$SALT'/" $f
done
