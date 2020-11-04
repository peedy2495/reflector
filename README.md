# reflector

## Intruduction

A tool for pulling different apt- and rpm-based repositories via rsync or web with automated config creation for related repositories via private web-provision.

## Startup

Add the executable flag to reflector.sh  
Start reflector.sh after modifying related configuration-files.  
Repository config files for rpm-sources will be stored in [basedest]/.repofiles.  
apt-configs are not supported yet ...

## Configuration

### reflector.conf
basedest - main store for all pulled repositories  
repourl - basic URL where your webservice resides.

### sources-yum-gpgkeys.conf
Get additional gpgkeys from used repositories

### sources-yum-rsync.conf
All rsync-based repositiories  
source, destination and tags have to be synced by line

### sources-yum-web.conf
All web-based repositories (http/https)  
source, options and tags have to be synced by line  
Refer wget for options

### sources-apt-patterns
keyring - path to the local gpg keyring  
You have to import the public repository gpg-key to your local keyring first, to be able to pull from defined repository.

### sources-apt-[source].conf
server - TLD of repository; like: "ftp.de.debian.org"  
inPath - subdirectory in TLD; like: "debian"  
release - relevant releases; like: "buster,buster-updates,buster-backports"  
section - relevant sections; like: "main,contrib,non-free"  
arch - used cpu-architecture; like : "i386,amd64"  
proto - used transfer-protocol; like: "http"  
outPath - destination path; recommended: "${basedest}${inPath}"