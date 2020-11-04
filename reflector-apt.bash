function apt_debmirror() {
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
}

function apt_lists() {
    if [ ! -d "${basedest}.apt" ]; then
        mkdir -p ${basedest}.apt
    fi
    dists=(${release//,/ })
    for dist in "${dists[@]}"; do
        echo "deb $repourl/$inPath $dist ${section//,/ }" >>${basedest}.apt/$server.${dist%%/*}.list
    done
}