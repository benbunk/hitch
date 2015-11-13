#!/bin/sh

#Building Hitch
#===
#
#  * autotools-dev
#  * automake1.9
#  * libtool
#  * autoconf
#  * libncurses-dev
#  * groff-base
#  * libpcre3-dev
#  * pkg-config
#  * Python Docutils
#  * Sphinx

sudo yum install -y git automake libev-devel python-docutils rpm-build ruby ruby-devel ruby-libs rubygems

# Packaging
sudo gem install fpm

#Cleanup
sudo yum erase hitch -y
rm -r /tmp/hitch
rm hitch/hitch_1.1.0_beta5_x86_64.rpm

git clone --branch hitch-init https://github.com/benbunk/hitch.git
cd hitch
./bootstrap
./configure
make
make install DESTDIR=/tmp/hitch

# Add an init script
mkdir -p /tmp/hitch/etc/rc.d/init.d
cp redhat/hitch.initrc       /tmp/hitch/etc/rc.d/init.d/hitch
chmod a+x /tmp/hitch/etc/rc.d/init.d/hitch
mkdir -p /tmp/hitch/etc/sysconfig/
cp redhat/hitch.sysconfig    /tmp/hitch/etc/sysconfig/hitch
cp redhat/hitch.afterinstall /tmp/hitch/
mkdir -p /tmp/hitch/usr/local/etc/
cp hitch.conf.ex             /tmp/hitch/usr/local/etc/hitch.conf

fpm -s dir -t rpm -n hitch -v 1.1.0-beta5 -C /tmp/hitch -p hitch_VERSION_ARCH.rpm --rpm-init /tmp/hitch/etc/rc.d/init.d/hitch --after-install=/tmp/hitch/hitch.afterinstall usr etc


# Install the local package
sudo yum localinstall -y hitch_1.1.0_beta5_x86_64.rpm

## Running HITCH with SystemV on redhat

sudo service hitch start
sudo service hitch stop
sudo service hitch reload

## Running HITCH Manually

# Generate temp key
#openssl genrsa -out www.example.com.key 2048
#openssl req -new -x509 -key www.example.com.key -out www.example.com.cert -days 3650 -subj /CN=www.example.com
#cat www.example.com.cert www.example.com.key > www.example.pem

#sudo /usr/local/sbin/hitch --backend=[127.0.0.1]:80 \
    --frontend=[*]:8443 \
    --sni-nomatch-abort \
    --daemon \
    --syslog \
    /export/home/r24042/www.example.pem
