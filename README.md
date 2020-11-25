# reflector

## Intruduction
A tool for pulling different apt- and rpm-based repositories via rsync or web with automated config creation for related repositories via private web-provision.
<br/><br/>

## WARNING!
Be aware that most repositories are eating a huge amount of disk-space!  
It's recommended to store your pulls into a separate Volume.
<br/><br/>

## Startup
Add the executable flag to `reflector.sh`  
Start `reflector.sh` after modifying related configuration-files.  
Repository config files for rpm-sources will be stored in [basedest]/.repofiles.
Repository config files for apt-sources will be stored in [basedest]/.apt.
<br/><br/>

## **Configuration**

### config/reflector.conf
basedest - main store for all pulled repositories  
repourl - basic URL where your webservice resides.
<br/><br/>

### config/../apt-keyring.conf
keyring - path to trustedkeys.gpg
<br/><br/>

### config/../yum-gpgkeys.conf
keys - array of URLs to public gpgkeys related to used repositories
<br/><br/>

### Repository configs
All config files may placed to different subfolders.
There are three types of Repository Configs
<br/><br/>

#### **RPMs managed by YUM/DNF**
Fileprefix: yum-  
*Content:*
```
tag - tag used by packagemanager
descr - repository description
src - URL-path
destination - additional subpath to [basedest]
yumdir - additional path to [basedest]/.repofile for repofile creation
pull - pull type; supported: rsync,web,wget,http,https,ftp,sftp. REFER #Pulltypes for additional options!
enabled - proceed this config? Considered values are 1/yes/true
```
<br/><br/>

#### **Managed by APT**
Fileprefix: apt-  
*Content:*
```
src - additional path to [basedest]/.apt for repofile creation
server - Servers's domainname
inPath - Path within the domainname
release - Version of the distributuion
section - Distribution sections
arch - needed CPU architectures
proto - used transfer protocol; supported: rsync,http,ftp
outPath - path to store to; unlike rpm-based repos the full path has to be defined. Example: ${basedest}my.example.com/${inPath}
enabled - proceed this config? Considered values are 1/yes/true
```
<br/><br/>

#### **RPMs unmanaged or unsupported packagemanager**
Fileprefix: misc-  
*Content:*  
```
descr - (optional) repository description
src - URL-path
destination - additional subpath to [basedest]
pull - pull type; supported: rsync,web,wget,http,https,ftp,sftp. REFER #Pulltypes for additional options!
enabled - proceed this config? Considered values are 1/yes/true
```

### **Pulltypes for rpm-based repositories**
#### **rsync**
no additional options provided.  
The URL-Path has to be defined without protocol prefix.  

#### **web,wget,http,https,ftp,sftp**
options - refer wget manpage for supported options  
cleanup - remove locally non-existent/removed files on host. Considered values are 1/yes/true
<br/><br/>
Remark to options:  
only use doublequotes for options, otherwise the content will be ignored by wget.  
Predefined reject options are ` -R "index.html*,robots.txt*" ` .