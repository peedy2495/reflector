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
### RPM-Section

get_required lib/reflector-RPM


#get_required lib/reflector-yum
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
#### APT - Section

get_required lib/reflector-apt
get_required apt-keyring.conf

while read conf
do
    get_source sources/$conf
    apt_debmirror
done < <(ls sources|grep sources-apt)
