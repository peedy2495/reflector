
function create_yum-repofile() {
    if [ ! -d "$path" ]; then
        mkdir -p $path
    fi
    repofile="$path/${tags[$tag]}.repo"
    echo "### auto generated file from upfRepos.sh as of $(date)" >$repofile
    echo "[${tags[$tag]}]" >>$repofile
    echo "name=$descr" >>$repofile
    echo "baseurl=$repourl/${destination[$i]}" >>$repofile
    echo "enabled=1" >>$repofile
    echo "metadata_expire=7d" >>$repofile
    echo "repo_gpgcheck=0" >>$repofile
    echo "type=rpm" >>$repofile
    echo "gpgcheck=0" >>$repofile
    echo "skip_if_unavailable=False" >>$repofile
}

function yum_rsync() {
    tag=0
    for i in "${!source[@]}"; do
        echo "syncing from ${source[$i]} to ${basedest}${destination[$i]} ..."
        if [ ! -d "${basedest}${destination[$i]}" ]; then
            mkdir -p ${basedest}${destination[$i]}
        fi
        rsync -avrt "rsync://${source[$i]}" "${basedest}${destination[$i]}" --delete-after

        path="${basedest}.repofiles/${tags[((tag+1))]}"
        descr="${tags[((tag+2))]}"
        if [[ "${tags[$tag]}" != "skip" ]]; then
            create_yum-repofile
            tag=$((tag + 3))
        else
            tag=$((tag + 1))
        fi
    done
}

function yum_wget() {
    tag=0
    for i in "${!source[@]}"; do
        echo "syncing from ${source[$i]} to ${basedest}${destination[$i]} ..."
        wget \
            --no-http-keep-alive\
            --no-cache\
            --no-cookies\
            -r\
            -np\
            -nc\
            -c\
            -R "index.html*,vscode*,robots.txt*"\
            ${options[$i]} ${source[$i]}\
            -P ${basedest}

        dest="${source[$i]}"
        dest="${dest#http://}"
        dest="${dest#https://}"
        destination[$i]="$dest"
        path="${basedest}.repofiles/${tags[((tag+1))]}"
        descr="${tags[((tag+2))]}"
        if [[ "${tags[$tag]}" != "skip" ]]; then
            create_yum-repofile
            tag=$((tag + 3))
        else
            tag=$((tag + 1))
        fi
    done
}

function yum_gpgkeys() {
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