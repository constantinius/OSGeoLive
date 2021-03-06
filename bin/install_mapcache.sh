#!/bin/sh
# Copyright (c) 2009-2019 The Open Source Geospatial Foundation and others.
# Licensed under the GNU LGPL version >= 2.1.
#
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 2.1 of the License,
# or any later version.  This library is distributed in the hope that
# it will be useful, but WITHOUT ANY WARRANTY, without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Lesser General Public License for more details, either
# in the "LICENSE.LGPL.txt" file distributed with this software or at
# web page "http://www.fsf.org/licenses/lgpl.html".
#
# About:
# =====
# This script will install mapcache
#
# Requires: Apache2
#
# Uninstall:
# ============
# sudo apt-get remove libmapcache1 mapcache-tools libapache2-mod-mapcache

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

# Install MapCache its command line tools and the MapCache Apache module
# the Apache module adds /etc/apache2/mods-enabled/mapcache.load
apt-get install --yes libmapcache1 mapcache-tools libapache2-mod-mapcache

# copy config files
MAPCACHE_DIR=/home/user/mapcache
mkdir -p "$MAPCACHE_DIR"
cp -f "$BUILD_DIR/../app-conf/mapcache/mapcache-quickstart.xml" "$MAPCACHE_DIR/mapcache-quickstart.xml"

# make a folder for the tilecache abd set the owner to be www-data
mkdir -p "$MAPCACHE_DIR/tilecache"
chown -R www-data:www-data "$MAPCACHE_DIR/tilecache"

# copy sample web app
MAPCACHE_WEB_DIR=/var/www/html/mapcache-quickstart
mkdir -p "$MAPCACHE_WEB_DIR"
cp -f "$BUILD_DIR/../app-conf/mapcache/index.html" "$MAPCACHE_WEB_DIR/index.html"
chmod -R uga+r "$MAPCACHE_WEB_DIR"

# Apache setup
APACHE_CONF_FILE="mapcache.conf"
APACHE_CONF_DIR="/etc/apache2/conf-available/"
APACHE_CONF_ENABLED_DIR="/etc/apache2/conf-enabled/"
APACHE_CONF=$APACHE_CONF_DIR$APACHE_CONF_FILE

# Add MapCache apache configuration
cat << EOF > "$APACHE_CONF"
<IfModule mapcache_module>
   <Directory /path/to/directory>
      Order Allow,Deny
      Allow from all
   </Directory>
   MapCacheAlias /mapcache "/usr/share/doc/libapache2-mod-mapcache/examples/mapcache.xml"
   MapCacheAlias /itasca "$MAPCACHE_DIR/mapcache-quickstart.xml" 
</IfModule>
EOF

a2enconf $APACHE_CONF_FILE

# Reload Apache
service apache2 --full-restart
echo "Finished configuring Apache"

# Add Launch icon to desktop
echo 'Downloading MapCache logo ...'
mkdir -p /usr/local/share/icons
wget -c --progress=dot:mega \
   -O /usr/local/share/icons/mapcache.png \
   "https://github.com/OSGeo/OSGeoLive-doc/raw/master/doc/images/projects/mapserver/logo_mapserver.png"

cat << EOF > "/usr/share/applications/mapcache.desktop"
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=MapCache
Comment=MapCache
Categories=Application;Education;Geography;
Exec=firefox http://localhost/mapcache/demo/ http://localhost/mapcache-quickstart/
Icon=mapcache
Terminal=false
StartupNotify=false
Categories=Education;Geography;
EOF

cp /usr/share/applications/mapcache.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME.$USER_NAME" "$USER_HOME/Desktop/mapcache.desktop"

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
