#!/usr/bin/env bash

. ./config.txt
. ./script/common_setup.sh

function setup_nfs_client
{
	cat <<_EOF > setup_tmp.$$.txt
# NFS client
rpcbind=YES
nfs_client=YES
lockd=YES
statd=YES
_EOF
	append_file_with_check 'rpcbind' /etc/rc.conf
}

function setup_nfs_mount
{
	cat <<_EOF > setup_tmp.$$.txt
# NFS mount
[ ! -d /usr/src ] && mkdir /usr/src
ping -c 4 ${REMOTE_HOST_IP}
if [ $? -eq 0 ]; then
	mount -t nfs ${REMOTE_HOST_IP}:/usr/src /usr/src
else
	echo '***'
	echo '*** WARN: Failed NFS mount.'
	echo '***'
fi
_EOF
	append_file_with_check 'rpcbind' /etc/rc.local
}

#
# setup environment
#
setup_hostname ${TARGET_HOST_NAME}

add_dhclient_config
add_devenv_network_config ${TARGET_HOST_IP} ${DEVEL_NETMASK}
add_hosts_entry
setup_pkg_path

setup_nfs_client
setup_nfs_mount

