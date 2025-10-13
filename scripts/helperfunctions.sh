#!/bin/bash
#
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

[ ! -e "/myhome/.ssh" ] && mkdir -p /myhome/.ssh && chmod 700 /myhome/.ssh
[ ! -e "/myhome/.ssh/authorized_keys" ] && touch /myhome/.ssh/authorized_keys 
[ -e "/myhome/.ssh/authorized_keys" ] && chmod 600 /myhome/.ssh/authorized_keys
[ -e "/myhome/.ssh/config" ] && chmod 600 /myhome/.ssh/config

echor()
{
    printf "${RED}[ >>>>>>>> ] $1 ${NC}\n"
}
echog()
{
    printf "${GREEN}[ OK       ] $1 ${NC}\n"
}
echob()
{
    printf "${BLUE}[ NOTE:    ] $1 ${NC}\n"
}

check_if_interactive_and_login_shell() {
	[[ $- == *i* ]] && echo '~/.bashrc: Interactive' || echo '~/.bashrc: Not interactive'
	shopt -q login_shell && echo '~/.bashrc: Login shell' || echo '~/.bashrc: Not login shell'
}

checkifroot() {
[ "$EUID" -ne 0 ] && echog "micromamba: To add packages, use an image with root priviliges as e.g. ubuntu"
}


countdown_timer() {
	seconds=20
	start="$(($(date +%s) + $seconds))"
	while [ "$start" -ge `date +%s` ]; do
		time="$(( $start - `date +%s` ))"
		printf '%s\r' "$(date -u -d "@$time" +%H:%M:%S)"
	done
}

check_ps_aux() {
	txtnr=$1
	sleeptime=$2

	out=`ps aux | grep '[a]pt'`
	out_lines_anz=`echo "$out" | wc -l`
	#[ "$out" != "" ] && sleep $sleeptime
	# [ "$out" != "" ] && echo "sleep $txtnr ($out_lines_anz processes) ==> sleep $sleeptime" && sleep $sleeptime
	[ "$out" != "" ] && sleep $sleeptime
	
	# echo "ok"
}

ssh_ubuntu_check() {
	install="False"
	[ "`command -v openssl`" = "" ] && install="True"
	[ ! -e "/etc/ssh" ] && install="True"
	[ ! -e "/usr/share/i18n/charmaps" ] && install="True"
	[ ! -e "/etc/ssh/sshd_config" ] && install="True"
	echo "$install"
	if [ "$install" = "True" ];then
		if [ "$1" = "verbose" ];then
			[ "`command -v openssl`" = "" ] && echor "ssh: install failed: openssl missing" && return
			[ ! -e "/etc/ssh" ] && echor "ssh: install failed: /etc/ssh does not exist but should." && return
			[ ! -e "/etc/ssh/sshd_config" ] && echor "ssh: /etc/ssh/sshd_config missing" && return
			[ ! -e "/usr/share/i18n/charmaps" ] && echor "ssh: /usr/share/i18n/charmaps missing" && return
		fi
	fi
}

ssh_enable_ubuntu() {
	install=`ssh_ubuntu_check`

	if [ "$install" != "False" ];then
		[ "$EUID" -ne 0 ] && echor "ssh: You can not enable ssh on this image since you are not root. Either use a different image where you got root priviliges or adapt this image." && return
		echog "ssh: For enabling ssh & scp : running: apt update -qq"
		check_ps_aux 1 2
		check_ps_aux 2 3
		check_ps_aux 3 3
		check_ps_aux 4 0
		apt update -qq 2>/dev/null >/dev/null;
		check_ps_aux 5 2
		check_ps_aux 6 3
		check_ps_aux 7 3
		check_ps_aux 8 0
		echog "ssh: For enabling ssh & scp : running: install openssh-server locales -qq -y; (~30 sec)"
		apt install openssh-server locales -qq -y 2>/dev/null >/dev/null;
		localedef -i en_US -f UTF-8 en_US.UTF-8
	fi

	install=`ssh_ubuntu_check "verbose"`
	[ "$install" != "False" ] && echor "ssh: Could not finish install of ssh dependencies" && return

	check1=`grep "^PermitRootLogin yes" /etc/ssh/sshd_config`
	[ "$check1" != "PermitRootLogin yes" ] && sed -i 's|^#PermitRootLogin prohibit-password$|PermitRootLogin yes|' /etc/ssh/sshd_config
	check1=`grep "^PermitRootLogin yes" /etc/ssh/sshd_config`
	[ "$check1" != "PermitRootLogin yes" ] && echor "ssh: could not set PermitRootLogin yes (/etc/ssh/sshd_config)" && return

	check1=`grep "^HostKey /myhome/hosts/ssh_host_rsa_key" /etc/ssh/sshd_config`
	[ "$check1" != "HostKey /myhome/hosts/ssh_host_rsa_key" ] && sed -i 's|^#HostKey /etc/ssh/ssh_host_rsa_key$|HostKey /myhome/hosts/ssh_host_rsa_key|' /etc/ssh/sshd_config
	check1=`grep "^HostKey /myhome/hosts/ssh_host_ecdsa_key" /etc/ssh/sshd_config`
	[ "$check1" != "HostKey /myhome/hosts/ssh_host_ecdsa_key" ] && sed -i 's|^#HostKey /etc/ssh/ssh_host_ecdsa_key$|HostKey /myhome/hosts/ssh_host_ecdsa_key|' /etc/ssh/sshd_config
	check1=`grep "^HostKey /myhome/hosts/ssh_host_ed25519_key" /etc/ssh/sshd_config`
	[ "$check1" != "HostKey /myhome/hosts/ssh_host_ed25519_key" ] && sed -i 's|^#HostKey /etc/ssh/ssh_host_ed25519_key$|HostKey /myhome/hosts/ssh_host_ed25519_key|' /etc/ssh/sshd_config
	check1=`grep "^HostKey /myhome/hosts/ssh_host_rsa_key" /etc/ssh/sshd_config`
	[ "$check1" != "HostKey /myhome/hosts/ssh_host_rsa_key" ] && echor "ssh: could not change the host keys (/etc/ssh/sshd_config)" && return

	# check1=`grep "^PasswordAuthentication no" /etc/ssh/sshd_config`
	# [ "$check1" != "PasswordAuthentication no" ] && sed -i 's|.*PasswordAuthentication yes|PasswordAuthentication no|' /etc/ssh/sshd_config
	# check1=`grep "^PasswordAuthentication no" /etc/ssh/sshd_config`
	# [ "$check1" != "PasswordAuthentication no" ] && echor "ssh: could not set PasswordAuthentication no (/etc/ssh/sshd_config)" && return


	check2=`/etc/init.d/ssh status`
	[ "$check2" != " * sshd is running" ] && /etc/init.d/ssh restart 2>/dev/null >/dev/null;
	check2=`/etc/init.d/ssh status`
	[ "$check2" != " * sshd is running" ] && echor "- sshd is not running: $check2" && return

	[ ! -e "/myhome/.profile" ] && touch /myhome/.profile && chmod ugo+rwx /myhome/.profile
	[ ! -e "/myhome/.profile" ] && echor "ssh: could not create /myhome/.profile" && return

	check3=`grep "^source /myhome/.bashrc" /myhome/.profile`
	[ "$check3" != "source /myhome/.bashrc" ] && echo "writing to ~/.profile" && echo "source /myhome/.bashrc" >> /myhome/.profile
	check3=`grep "^source /myhome/.bashrc" /myhome/.profile`
	[ "$check3" != "source /myhome/.bashrc" ] && echor "ssh: could not adapt /myhome/.profile :" && return

	sed -i 's|:root:/root:|:root:/myhome:|' /etc/passwd
	
	# echog "- localedef -i en_US -f UTF-8 en_US.UTF-8"
	# localedef -i en_US -f UTF-8 en_US.UTF-8

	echo "root:root" | chpasswd

	not_login_shell_1() {
	echog "ssh: To ssh to this container AND/OR to forward yor ssh-keys, run on your local machine:"
	echog "                 a) \"runai port-forward $JOB_NAME --port 2222:22 >/dev/null &\" and then"
	echog "                 b) \"ssh root@localhost -p 2222\" (password: \"root\"):"
	}

	shopt -q login_shell && login_shell=1 || not_login_shell_1
	#echog "ssh: You can ssh to this container a) Run: \"runai port-forward <JOBNAME> --port 2222:22\" and b: \"ssh root@localhost -p 2222\" (password: \"root\"):"
	if [ "`command -v ssh-add`" != "" ];then
		keys=`ssh-add -l 2>/dev/null`
		if [ "$keys" != "" ];then
			echog "ssh: You forwarded following keys (ssh-add -l):"
			while IFS= read -r line; do
				echog "     $line"
			done <<< "$keys"
			# for i in $keys;do
			# 	echog "ssh: $i"
			# done
		else
			shopt -q login_shell && login_shell=1
			if [ "$login_shell" != "1" ];then
				# connected with runai bash
				echob "ssh (a): If you want to forward ssh keys, you need to ssh to this container and not connect using runai bash <jobname>."
			else
				# connected with ssh
				echob "ssh (b): You did not forward ssh-keys; To forward ssh-keys use ssh-add <PATH_TO_KEY> on your local machine;"
			fi

		fi
	fi

}

