#!/bin/bash

#Get all repositories from online sources
# estimated total Size ~650GB

main() {
    cd "$(dirname "$0")"
    get_required reflector.conf
    do_yum
    #do_apt
    exit 0
 }

do_yum() {
###############################
### Repositories Managed by YUM

    while read conf
    do
        if get_source $conf; then
            yum_mirror
        fi
    done < <(find sources -name 'yum-*')
    
    ## get GPG-Keys for Package verification
    if get_source yum-gpgkeys.conf; then
        yum_gpgkeys
    fi
}

do_apt() {
###############################
### Repositories Managed by APT
    get_required apt-keyring.conf

    while read conf
    do
        if get_source $conf; then
            apt_debmirror
        fi
    done < <(find sources -name 'apt-*')
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

yum_mirror() {
    if [[ ${enabled,,} =~ ^(1|yes|true)$ ]]; then

        if [[ ${pull,,} =~ ^(rsync)$ ]]; then
            yum_rsync
        elif [[ ${pull,,} =~ ^(web|wget|http|https|ftp|sftp)$ ]]; then
            yum_wget
        fi
    fi
}

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

yum_rsync() {
    echo "syncing from ${source} to ${basedest}${destination} ..."
    if [ ! -d "${basedest}${destination}" ]; then
        mkdir -p ${basedest}${destination}
    fi
    rsync -avrt "rsync://${source}" "${basedest}${destination}" --delete-after
    if [[ "${tag}" != "skip" ]]; then
        path="${basedest}.repofiles/${yumdir}"
        create_yum-repofile
    fi
}

yum_wget() {
    echo "syncing from ${source} to ${basedest}${destination} ..."
    wget \
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
        ${source}\
        -P ${basedest}
    if [[ "${tag}" != "skip" ]]; then
        dest="${source}"
        dest="${dest#http://}"
        dest="${dest#https://}"
        destination="$dest"
        path="${basedest}.repofiles/${tag}"
        create_yum-repofile
    fi
}

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
 
        wget $key -O "${basedest}/.keys/$host.key"
    done
}

apt_debmirror() {
    if [[ ${enabled,,} =~ ^(1|yes|true)$ ]]; then
        if [ -d "${basedest}.apt/$source" ]; then
            rm -rf "${basedest}.apt/$source"
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

apt_lists() {
    if [ ! -d "${basedest}.apt/$source" ]; then
        mkdir -p ${basedest}.apt/$source
    fi
    releases=(${release//,/ })
    for rel in "${releases[@]}"; do
        echo "deb $repourl/$inPath $rel ${section//,/ }" >>${basedest}.apt/$source/$server.${rel%%/*}.list
    done
}

#####################################
# Call main function to run this tool
main