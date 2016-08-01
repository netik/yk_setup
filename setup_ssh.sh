#!/bin/bash

function append_profile() { 
  echo ". /usr/local/bin/ssh_agent_detect.sh" >> ~/.bash_profile
}

# setup ssh
echo "This is your SSH pubkey for this yubikey in ~/pubkey/ssh-pubkey."
echo
gpgkey2ssh `gpg --with-colons --list-keys | grep :a: | awk -F: '{ print $5 }'` > ~/pubkey/ssh-pubkey
cat ~/pubkey/ssh-pubkey
echo

echo "[*] Install our detect script..."
sudo cp ./ssh_agent_detect.sh /usr/local/bin
sudo chmod 755 /usr/local/bin/ssh_agent_detect.sh

echo "[*] Adding agent detection script to .profile..."
if [ ! -f ~/.bash_profile ]; then
  append_profile
else
  grep ssh_agent_detect ~/.bash_profile > /dev/null

  if [ $? != 0 ]; then 
      append_profile
  fi
fi

echo "[*] enable ssh support in agent."
cp gpg-agent.conf ~/.gnupg/gpg-agent.conf
