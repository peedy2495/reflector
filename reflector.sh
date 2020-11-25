#!/bin/bash

#Get all repositories from online sources
# estimated total Size ~650GB

main() {
    rdir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
    cd ${rdir}
    get_required config/reflector.conf
    do_yum
    do_apt
    do_misc
    exit 0
 }

do_yum() {
###############################
### Repositories Managed by YUM

    while read conf
    do
        if get_source $conf; then
            rpm_mirror
        fi
    done < <(find config -name 'yum-*')
    
    ## get GPG-Keys for Package verification
    yumgpg=$(find config -name 'yum-gpgkeys.conf')
    if get_source ${yumgpg}; then
        yum_gpgkeys
    fi
}

do_apt() {
###############################
### Repositories Managed by APT
    aptgpg=$(find config -name 'apt-keyring.conf')
    get_required ${aptgpg}

    while read conf
    do
        if get_source $conf; then
            apt_debmirror
        fi
    done < <(find config -name 'apt-*')
    }

do_misc() {
###############################
### Misc raw Repositories

    while read conf
    do
        if get_source $conf; then
            rpm_mirror
        fi
    done < <(find config -name 'misc-*')
}

get_source() {
# check and read the called sourcefile
    local file=$1
    if [ -f "$file" ]; then
        source $file
    else
        echo "File $file not found!"
        return 1
    fi
}

get_required() {
# check and read the called sourcefile like get_source().
# but the called files are striktly required.
# Because of this, any fail ends into a hard interrupt.
    local file=$1
    if [ -f "$file" ]; then
        source $file      
    else
        echo "File $file not found!"
        exit 1
    fi
}

### check repo-activation and switch by pulltype
rpm_mirror() {
    if [[ ${enabled,,} =~ ^(1|yes|true)$ ]]; then

        if [[ ${pull,,} =~ ^(rsync)$ ]]; then
            rpm_rsync
        elif [[ ${pull,,} =~ ^(web|wget|http|https|ftp|sftp)$ ]]; then
            rpm_wget
        fi
    fi
    ## unset vars intentionally left duplicates 
    unset tag descr src destination yumdir pull enabled     #rsync config
    unset tag descr src yumdir pull options cleanup enabled #wget config
}

### create repository definition for yum/dnf pointing to your private webhost
create_yum-repofile() {
    if [ ! -d "$path" ]; then
        mkdir -p $path
    fi
    repofile="$path/${tag}.repo"
    echo "### auto generated file from upfRepos.sh as of $(date)" >$repofile
    echo "[${tag}]" >>$repofile
    echo "name=$descr" >>$repofile
    echo "baseurl=$repourl/${destination[$i]}" >>$repofile
    echo "enabled=1" >>$repofile
    echo "metadata_expire=7d" >>$repofile
    echo "repo_gpgcheck=0" >>$repofile
    echo "type=rpm" >>$repofile
    echo "gpgcheck=0" >>$repofile
    echo "skip_if_unavailable=False" >>$repofile
}

### create/update repo with rysnc
rpm_rsync() {
    echo "syncing from ${src} to ${basedest}${destination} ..."
    if [ ! -d "${basedest}${destination}" ]; then
        mkdir -p ${basedest}${destination}
    fi
    rsync -avrt "rsync://${src}" "${basedest}${destination}" --delete-after
    if [[ ! -z "${yumdir}" ]]; then
        path="${basedest}.repofiles/${yumdir}"
        create_yum-repofile
    fi
}

### create/update repo with wget
rpm_wget() {
    dest="${src}"
    dest="${dest#http://}"
    dest="${dest#https://}"
    dest="${dest#ftp://}"
    dest="${dest#sftp://}"
    destination="$dest"
    echo "syncing from ${src} to ${basedest}${destination} ..."
    wget \
        -nv\
        --no-http-keep-alive\
        --no-cache\
        --no-cookies\
        -e robots=off\
        -r\
        -np\
        -N\
        -c\
        -R "index.html*,robots.txt*"\
        ${options}\
        ${src}\
        -P ${basedest}
    if [[ ${cleanup,,} =~ ^(1|yes|true)$ ]]; then
        rpm_wget_cleanup
    fi
    if [[ ! -z "${yumdir}" ]]; then
        path="${basedest}.repofiles/${tag}"
        create_yum-repofile
    fi
}

### remove deprecated local files
rpm_wget_cleanup() {
    cd ${basedest}${destination}
    while read target; do
        if ! wget -nv --spider ${src}${target}; then
            rm -f ${target}
            echo "removed: File ${target}" 
        fi
    done < <(find *)
    cd ${rdir}
}

### pull necessary gpg-key for offline-clients
yum_gpgkeys() {
    for key in "${keys[@]}"; do
        ## Remove protocol part of url  ##
        host="${key#http://}"
        host="${host#https://}"
        host="${host#ftp://}"
        host="${host#scp://}"
        host="${host#scp://}"
        host="${host#sftp://}"
        ## Remove username and/or username:password part of URL  ##
        host="${host#*:*@}"
        host="${host#*@}"
        ## Remove rest of urls ##
        host=${host%%/*}
 
        wget $key -c -N -O "${basedest}/.keys/$host.key"
    done
}

### create/update debian based repo
apt_debmirror() {
    if [[ ${enabled,,} =~ ^(1|yes|true)$ ]]; then
        if [ -d "${basedest}.apt/$src" ]; then
            rm -rf "${basedest}.apt/$src"
        fi
        debmirror       -a $arch \
                        --nosource \
                        -s $section \
                        -h $server \
                        -d $release \
                        -r $inPath \
                        --progress \
                        --method=$proto \
                        --keyring=$keyring \
                        $outPath
        apt_lists
    fi
}

### create repository definition for apt pointing to your private webhost
apt_lists() {
    if [ ! -d "${basedest}.apt/$src" ]; then
        mkdir -p ${basedest}.apt/$src
    fi
    releases=(${release//,/ })
    for rel in "${releases[@]}"; do
        echo "deb $repourl/$inPath $rel ${section//,/ }" >>${basedest}.apt/$src/$server.${rel%%/*}.list
    done
}

#####################################
# Call main function to run this tool
main