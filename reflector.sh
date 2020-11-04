#!/bin/bash
cd "$(dirname "$0")"
#Get all repositories from online sources
# estimated total Size ~650GB

function get_source() {
    local file=$1
    if [ -f "$file" ]; then
        source $file
    else
        echo "File $file not found!"
        return 1
    fi
}

function get_required() {
    local file=$1
    if [ -f "$file" ]; then
        source $file      
    else
        echo "File $file not found!"
        exit 1
    fi
}

get_required reflector.conf

#########################
### YUM/DNF Reposiories

#get_required reflector-yum.bash
#
##remove all previous repofiles for recreation
#if [ -d "${basedest}.repofiles" ]; then
#    rm -rf "${basedest}.repofiles"
#fi
#
### Yum-Repos via rsync
#get_source sources-yum-rsync.conf
#yum_rsync
#
### Yum-Repos via wget
#get_source sources-yum-web.conf
#yum_wget
#
### get GPG-Keys for Package verification
#get_source sources-yum-gpgkeys.conf
#yum_gpgkeys

##########################
#### APT Ubuntu Mirror
get_required reflector-apt.bash
get_required sources-apt-patterns.conf
#
##remove all previous repofiles for recreation
if [ -d "${basedest}.apt" ]; then
    rm -rf "${basedest}.apt"
fi
#
## Main Rerpository
get_source sources-apt-archive.canonical.com-ubuntu.conf
apt_debmirror
#

##########################
#### APT Debian Mirror
#get_required reflector-apt.bash
#get_required sources-apt-patterns.conf
#
##remove all previous repofiles for recreation
#if [ -d "${basedest}.apt" ]; then
#    rm -rf "${basedest}.apt"
#fi
#
## Main Rerpository
#get_source sources-apt-ftp.de.debian.org.conf
#apt_debmirror
#
## Security Repository
#get_source sources-apt-security.debian.org.conf
#apt_debmirror
#
### Proxmox PVE repository
#get_source sources-apt-enterprise.proxmox.com.conf
#apt_debmirror
#
### Docker CE repository
#get_source sources-apt-download.docker.com.conf
#apt_debmirror
#
### GlusterFS repository
#get_source sources-apt-download.gluster.org.conf
#apt_debmirror
#
### Deploy to Mobile Drive
##rsync -rtv /data/deploy/* /run/media/bigdata/te_we/deploy/ --delete-after