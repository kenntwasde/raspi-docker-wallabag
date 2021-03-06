# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM kenntwasde/raspi_baseimage-docker:wheezy
MAINTAINER Michael Nieberg <m.nieberg@gmx.de>>

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Install locales
#ENV DEBIAN_FRONTEND noninteractive

# MN in debian language must be enabled in /etc/locale.gen
RUN	set -e; set -x; \
        for lang in cs_CZ de_DE es_ES fr_FR it_IT pl_PL pt_BR ru_RU sl_SI uk_UA; \
	do \
		sed -i "s/# $lang\.UTF-8/$lang\.UTF-8/" /etc/locale.gen; \
	done ; \
	locale-gen 

# Install wallabag prereqs
#RUN add-apt-repository ppa:nginx/stable \
#    && apt-get update \
#    && apt-get install -y nginx php5-cli php5-common php5-sqlite \
#          php5-curl php5-fpm php5-json php5-tidy wget unzip gettext

RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update \
    && apt-get install -y --no-install-recommends \
	nginx \
	php5-cli \
	php5-common \
	php5-sqlite \
        php5-curl \
	php5-fpm \
	php5-json \
	php5-tidy \
	php5-gd \
	wget \
	unzip \
	gettext


# Configure php-fpm
RUN \
	echo "cgi.fix_pathinfo = 0" >> /etc/php5/fpm/php.ini && \
	echo "daemon off;" >> /etc/nginx/nginx.conf

COPY www.conf /etc/php5/fpm/pool.d/www.conf

RUN mkdir /etc/service/php5-fpm
COPY php5-fpm.sh /etc/service/php5-fpm/run

RUN mkdir /etc/service/nginx
COPY nginx.sh /etc/service/nginx/run

# Wallabag version
ENV WALLABAG_VERSION 1.9

# Extract wallabag code
#ADD https://github.com/wallabag/wallabag/archive/$WALLABAG_VERSION.zip /tmp/wallabag-$WALLABAG_VERSION.zip
#ADD http://wllbg.org/vendor /tmp/vendor.zip

#RUN mkdir -p /var/www
#RUN cd /var/www \
#    && unzip -q /tmp/wallabag-$WALLABAG_VERSION.zip \
#    && mv wallabag-$WALLABAG_VERSION wallabag \
#    && cd wallabag \
#    && unzip -q /tmp/vendor.zip \
#    && cp inc/poche/config.inc.default.php inc/poche/config.inc.php \
#    && cp install/poche.sqlite db/

RUN set -e ; set -x; \
    mkdir -p /var/www \
    && cd /var/www \
    && curl -sLS https://github.com/wallabag/wallabag/archive/$WALLABAG_VERSION.zip > /tmp/wallabag-$WALLABAG_VERSION.zip \
    && unzip -q /tmp/wallabag-$WALLABAG_VERSION.zip \
    && mv wallabag-$WALLABAG_VERSION wallabag \
    && cd wallabag \
    && curl -sLS http://getcomposer.org/installer | php \
    && php composer.phar install \
    && cp install/poche.sqlite db/ \
    && echo "done for now"

# do not copy config-file, otherwise setup will not start 
#    && cp inc/poche/config.inc.default.php inc/poche/config.inc.php \

# do not copy this file
# the setup-routine is writing one
COPY 99_change_wallabag_config_salt.sh /etc/my_init.d/99_change_wallabag_config_salt.sh

RUN \
	rm -f /tmp/wallabag-$WALLABAG_VERSION.zip /tmp/vendor.zip; \
	echo "not removing /var/www/wallabag/install"

# MN: if install not present, wallabag does no setup-routine
#	rm -rf /var/www/wallabag/install

RUN \
	chown -R www-data:www-data /var/www/wallabag && \
	chmod 755 -R /var/www/wallabag

# Configure nginx to serve wallabag app
COPY nginx-wallabag /etc/nginx/sites-available/default

EXPOSE 80

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
