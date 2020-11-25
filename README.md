# reflector

## Introduction
A tool for pulling different apt- and rpm-based repositories via rsync or web with automated config creation for related repositories via private web-provision.
<br/><br/>

## WARNING!
Be aware that most repositories are eating a huge amount of disk-space!  
It's recommended to store your pulls into a separate Volume.
<br/><br/>

## Startup
Add the executable flag to `reflector.sh`  
Start `reflector.sh` after modifying related configuration-files.  
Repository config files for rpm-sources will be stored in `[basedest]/.repofiles` .  
Repository config files for apt-sources will be stored in `[basedest]/.apt` .
<br/><br/>

## **Configuration**

*config/reflector.conf*
```
basedest        - main store for all pulled repositories  
repourl         - basic URL where your webservice resides.
```

*config/../apt-keyring.conf*
```
keyring         - path to trustedkeys.gpg to be able to copy the repository 
```

Example import of a downloaded public GPG-Key  
```
wget https://download.gluster.org/pub/gluster/glusterfs/7/rsa.pub -P [basedest]/.keys/keypath/goodfilename.pub
gpg --no-default-keyring --keyring [keyring] --import [basedest]/.keys/keypath/rsa.pub
```
Required GPG-keys have to be imported into the clients, too. 

*config/../yum-gpgkeys.conf*
```
keys        - array of URLs to public gpgkeys related to used repositories  
```
These will only be downloaded to `[basedets]/.keys` and have to be imported into the clients
<br/><br/>

### Repository configs
All config files may placed to different subfolders.
Some sample folders and config files (disabled) are included to get closer with the configuration.  
Regarding to apt, don't forget to import needed GPG-keys before trying any apt-configs.  
There are three types of repository configs
<br/><br/>

#### **RPMs managed by YUM/DNF**
Fileprefix: yum-  
*Content:*
```
tag         - tag used by packagemanager
descr       - repository description
src         - URL-path
destination - additional subpath to [basedest]
yumdir      - additional path to [basedest]/.repofile for repofile creation
pull        - pull type; supported: rsync,web,wget,http,https,ftp,sftp
              REFER #Pulltypes for additional options!
enabled     - proceed this config? Considered values are 1/yes/true
```
<br/><br/>

#### **Managed by APT**
Fileprefix: apt-  
*Content:*
```
src         - additional path to [basedest]/.apt for repofile creation
server      - servers's domainname
inPath      - path within the domainname
release     - version of the distributuion
section     - distribution sections
arch        - needed CPU architectures
proto       - used transfer protocol; supported: rsync,http,ftp
outPath     - path to store to; unlike rpm-based repos the full path has to be defined.
              Example: ${basedest}my.example.com/${inPath}
enabled     - proceed this config? Considered values are 1/yes/true
```
<br/><br/>

#### **RPMs unmanaged or unsupported packagemanager**
Fileprefix: misc-  
*Content:*  
```
descr       - (optional) repository description
src         - URL-path
destination - additional subpath to [basedest]
pull        - pull type; supported: rsync,web,wget,http,https,ftp,sftp
              REFER #Pulltypes for additional options!
enabled     - proceed this config? Considered values are 1/yes/true
```

### **Pulltypes for rpm-based repositories**
#### **rsync**
no additional options provided.  
The URL-path has to be defined without protocol prefix.  

#### **web,wget,http,https,ftp,sftp**
The URL-Path has to defined with protocol prefix.  
Refer wget manpage for protocol capabilities.
```
options     - refer wget manpage for supported options  
cleanup     - remove locally non-existent/removed files on host. Considered values are 1/yes/true
```
<br/><br/>
Remark to options:  
only use doublequotes for options, otherwise the content will be ignored by wget.  
Predefined reject options are ` -R "index.html*,robots.txt*" ` .