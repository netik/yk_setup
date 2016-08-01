#!/bin/bash
#
# yubikey_setup.sh
#
# J. Adams <jna@bolt.me> 
# 7/27/2016
#
# Set up GPG keys and your yubikey neo.
#
# Run me first!
#

unset KEYID
export USBTMP=${HOME}/USB
MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TODAY=`date +'%Y-%m-%d'`

clear
cat <<EOF

Welcome to Bolt Yubikey Setup.
---------------------------------
=== THIS SCRIPT REPLACES EXISTING GPG CONFIGURATIONS AND KEYS 
=== USE CAUTION! 

Please note: 

If you have an existing .gnupg directory it will be moved to
.gnupg.orig when you start the install.

This script configures a Yubikey NEO for use for:

  -- GPG Encrypting and Singing
  -- SSH private key storage
  -- Fido/U2F

[1] INSERT A NEW YUBIKEY NOW and ensure that you have a connection to
    the Internet.

[2] When MacOS prompts you to identify the unknown keyboard, close
    the window. 

EOF

echo -n "Press RETURN to start or Control-C to abort: "
read INPUT

clear
echo -n "[*] Yubikey setup starting at " 
/bin/date

echo "[*] Make USB dir..."

if [ -d ${HOME}/USB ]; then 
  echo "[!] Warning: $HOME/USB exists"

  echo -n "Press enter to destroy it and start over:"
  read INPUT

  rm -rf ${USBTMP}
  mkdir ${USBTMP}
fi

mkdir ${USBTMP}

# download mac gpg
if [ ! -f ~/Downloads/GPG_Suite-2016.07_v2.dmg ]; 
then
  echo "[*] Download Mac GPG"
  (cd ~/Downloads; curl -O https://releases.gpgtools.org/GPG_Suite-2016.07_v2.dmg)
else
  echo "[*] Skip Mac GPG download, we have it."
fi

# install mac gpg
if [ ! -f /usr/local/bin/gpg ]; 
then
  echo "[*] Install Mac GPG -- please enter your password when prompted."
  open GPG_Suite-2016.07_v2.dmg
  sudo installer -pkg /Volumes/GPG\ Suite/Install.pkg -target /
  umount /Volumes/GPG\ Suite

else
  echo "[*] Skip Mac GPG install, we have it."
fi

# since this is a new install, we must also destroy the default
# GnuPG dir the installer so helpfully adds.

echo "[*] Create new GPG Dir"
if [ -e $HOME/.gnupg ]; then
    echo "[*] Moving existing dir from .gnupg to .gnupg.old"
    mv ${HOME}/.gnupg ${HOME}/.gnupg.old
fi

# Make sure to store the master key on the USB drive
ln -s ${USBTMP} ${HOME}/.gnupg

# Set GnuPG to prefer strong hash and encryption algorithms
echo "cert-digest-algo SHA512" >> .gnupg/gpg.conf
echo "default-preference-list SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed" >> .gnupg/gpg.conf

# start GPG setup
echo "[*] We're going to create your GPG key now."
echo

${MYDIR}/genkey.expect

# fix GPG dir perms
chmod -R og-rwx ~/.gnupg
chmod -R og-rwx ${USBTMP}

# generate revocation cert
export KEYID=`gpg --list-keys | grep pub | grep 2048 | cut -d/ -f2 | cut -d' ' -f1`

echo "[*] generate revocation certificate for later use"
${MYDIR}/genrevoke.expect

# generate encryption subkeys
echo "[*] generate encryption subkeys"
${MYDIR}/gensubkeys.expect

export SUBKEYID=`gpg --list-keys | grep sub | grep 2048 | cut -d/ -f2 | cut -d' ' -f1`

# backup secret keys
echo "[*] backup encryption secret"
SECFN=${USBTMP}/${KEYID}-${TODAY}-${SUBKEYID}-secret.pgp
gpg --export-secret-key $KEYID > ${SECFN}
chmod 600 ${SECFN}

# export the pubkey
echo "[*] I am exporting your public key to ~/pubkey/${KEYID}-pub.asc."
echo "[*] You can upload this to keybase or another public place."
if [ ! -d ~/pubkey ]; then 
  mkdir ~/pubkey
fi
gpg --armor --export $KEYID > ~/pubkey/${KEYID}-pub.asc

# move the keys.
echo "Now run: "
echo ${MYDIR}/move_keys_to_card.sh

