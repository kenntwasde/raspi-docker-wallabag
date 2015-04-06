## no release yet    raspi_0.0.17 (release date: 2015-04-06)
 * new branch raspi
 - this image is for the raspberr pi2 (armv7l)
 * Dockerfile
 - reduced steps
 - do not delete init-folder, otherwise setup will not start
 - if configfile is there, setup will not start setup!
	=> apply salt-magic to config-template
 * 99_change_wallabag_config_salt.sh
 - only replace salt when given by docker run ... --env WALLABAG_SALT	 
   (and copy default config then!)

