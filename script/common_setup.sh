# common_setup.sh

#
# util function
#
function append_file
{
	fname=$1
	if [ ! -z "${fname}" ]; then
		if [ ${DRY_RUN} -eq 0 ]; then
			if [ -f ${fname} ]; then
				# file backup
				cp -pi ${fname} ${fname}.before
			fi
			cat setup_tmp.$$.txt >> ${fname}
		else
			echo cat setup_tmp.$$.txt ' >> ' ${fname}
		fi
	fi
}

function append_file_with_check
{
	keyword=$1
	fname=$2

	grep ${keyword} ${fname} > /dev/null
	if [ $? -ne 0 -o ! -f ${fname} ]; then
		append_file ${fname}
	fi
}

function pkg_add_if_not_exist
{
	pkgname=$1
	pkg_info -a | grep ${pkgname} > /dev/null
	if [ $? -ne 0 ]; then
		pkg_add -v ${pkgname}
	fi
}

#
# common procedure
#
function setup_hostname
{
	newname=$1
	if [ ! -z "${newname}" ]; then
		cat <<_EOF > setup_tmp.$$.txt
${newname}
_EOF
	append_file 'dhclient' /etc/myname

	fi
}

function add_dhclient_config
{
	cat <<_EOF > setup_tmp.$$.txt
# DHCP setting.
dhclient=YES
dhclient_flags="wm0"
_EOF
	append_file_with_check 'dhclient' /etc/rc.conf
}

function add_devenv_network_config
{
	addr=$1
	mask=$2
	cat <<_EOF > setup_tmp.$$.txt
up
${addr} ${mask}
_EOF
	append_file_with_check "${addr}" /etc/ifconfig.wm1
}

function add_hosts_entry
{
	cat <<_EOF > setup_tmp.$$.txt
# hostname entry
${TARGET_HOST_IP}	${TARGET_HOST_NAME}
${REMOTE_HOST_IP}	${REMOTE_HOST_NAME}
_EOF
	append_file_with_check "${TARGET_HOST_IP}" /etc/hosts
}

function setup_pkg_path
{
	cat <<_EOF > setup_tmp.$$.txt
	export PKG_PATH=ftp://ftp.NetBSD.org/pub/pkgsrc/packages/NetBSD/$(uname -m)/${NETBSD_VERSION}/All
_EOF
	# XXX need check '^export PKG_PATH=...'
	append_file /root/.profile

	source /root/.profile
}

