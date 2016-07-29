#!/bin/bash

function append_profile() { 
  echo ". /usr/local//bin/ssh_agent_detect.sh" >> ~/.profile
}

# setup ssh
echo "This is your SSH pubkey for this yubikey in ~/pubkey/ssh-pubkey."
echo
gpgkey2ssh `gpg --with-colons --list-keys | grep :a: | awk -F: '{ print $5 }'` > ~/pubkey/ssh-pubkey
cat ~/pubkey/ssh-pubkey
echo

# if we are on el capitan, we have to deal with system integrity protection.
if [ -f /usr/bin/csrutil ]; then 
    STATE=`/usr/bin/csrutil status | grep enabled`

    if [ $? = 0 ]; then 
      echo "[!!] Can't disable native GPG agent."
      echo
      echo "[!!] You are on el Capitan or greater with integrity protection enabled."
      echo "[!!] We need to disable it for to turn off gpg-agent."
 
cat <<EOF

Perform the following:

1. Boot in to recovery mode (reboot, hold "R")
2. Run a terminal, issue csrutil disable
3. Re-run this script. Reboot. 
4. Boot in to recovery mode (reboot, hold "R")
5. Run a terminal, issue csrutil enable

EOF
      exit 
    fi
fi

echo "[*] Disabling native Apple gpg-agent..."

# we don't want this one, we want MacGPG! 
launchctl unload -w /System/Library/LaunchAgents/org.openbsd.ssh-agent.plist

cp ./ssh_agent_detect.sh /usr/local/bin
chmod 755 /usr/local/bin/ssh_agent_detect.sh

echo "Adding agent detection script to .profile..."
if [ ! -f ~/.profile ]; then
  append_profile
else
  grep ssh_agent_detect ~/.profile

  if [ $? == 0 ]; then 
      append_profile
  fi
fi


