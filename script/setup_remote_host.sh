#!/usr/bin/env bash

. ./config.txt
. ./script/common_setup.sh

function setup_nfs_server
{
	cat <<_EOF > setup_tmp.$$.txt
# NFS server
rpcbind=YES
mountd=YES
nfs_server=YES
lockd=YES
statd=YES
_EOF
	append_file_with_check 'rpcbind' /etc/rc.conf
}

function setup_exports_file
{
	cat <<_EOF > setup_tmp.$$.txt
/usr/src -maproot=root:wheel	${TARGET_HOST_IP}
_EOF
	append_file_with_check '/usr/src' /etc/exports
}

function donwload_source_and_extract
{
	URL=ftp://ftp.jaist.ac.jp/pub/NetBSD/NetBSD-$(uname -r)/source/sets/
	saved_curdir=`pwd`

	[ ! -f /usr/src/Download ] && mkdir -p /usr/src/Download
	cd /usr/src/Download

	pkg_add_if_not_exist curl

	curl -O ${URL}/gnusrc.tgz
	curl -O ${URL}/sharesrc.tgz
	curl -O ${URL}/gnusrc.tgz
	curl -O ${URL}/src.tgz
	curl -O ${URL}/syssrc.tgz
	#curl -O ${URL}/xsrc.tgz

	cd ..
	tar zxvf Download/gnusrc.tgz   -C /
	tar zxvf Download/sharesrc.tgz -C /
	tar zxvf Download/gnusrc.tgz   -C /
	tar zxvf Download/src.tgz      -C /
	tar zxvf Download/syssrc.tgz   -C /
	#tar zxvf Download/xsrc.tgz     -C /

	cd ${saved_curdir}
}

#
# setup environment
#
setup_hostname ${REMOTE_HOST_NAME}

add_dhclient_config
add_devenv_network_config ${REMOTE_HOST_IP} ${DEVEL_NETMASK}
add_hosts_entry
setup_pkg_path

setup_nfs_server
setup_exports_file

donwload_source_and_extract

