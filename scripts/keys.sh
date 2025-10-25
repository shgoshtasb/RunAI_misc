#!/bin/bash
# Ensure /myhome/hosts exists
mkdir -p /myhome/hosts
chmod 700 /myhome/hosts
chown root:root /myhome/hosts

# Update sshd_config entries
for type in rsa ecdsa ed25519; do
    key="/myhome/hosts/ssh_host_${type}_key"
    grep -q "^HostKey ${key}$" /etc/ssh/sshd_config || {
        # Replace the default commented line if found, else append
        if grep -q "^#HostKey /etc/ssh/ssh_host_${type}_key" /etc/ssh/sshd_config; then
            sed -i "s|^#HostKey /etc/ssh/ssh_host_${type}_key|HostKey ${key}|" /etc/ssh/sshd_config
        else
            echo "HostKey ${key}" >> /etc/ssh/sshd_config
        fi
    }
    # Generate missing key if needed
    [ ! -f "$key" ] && ssh-keygen -t "$type" -f "$key" -N ""
done
