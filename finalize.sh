#!/bin/bash
#
# finalize.sh
#
# J. Adams <jna@bolt.me> 
# 7/27/2016
#
# this script removes your .gnupg dir, moves your key to your card and
# sets up ssh.
#
#

export USBTMP=${HOME}/USB

MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TODAY=`date +'%Y-%m-%d'`

export KEYID=`gpg --list-keys | grep pub | grep 2048 | cut -d/ -f2 | cut -d' ' -f1`

# destroy the symlink
if [ -L $HOME/.gnupg ]; 
then
  echo "[*] Removing .gnupg symlink"

  rm $HOME/.gnupg
  echo
  echo "[*] REMOVE AND REINSERT THE YUBIKEY NOW. Type [y] when ready!"

  INPUT=""
  while [ "$INPUT" != "y" ]; do 
    echo -n "[y]:"
    read INPUT
  done

else
  # the symlink is gone, so we have to get the KEYID a different way...
  echo "[*] Get keyID from $HOME/USB"
  if [ -d $HOME/USB ]; then
    export KEYID=`env GNUPGHOME=${HOME}/USB gpg --list-keys | grep pub | grep 2048 | cut -d/ -f2 | cut -d' ' -f1`
  else
    echo "[!] No $HOME/USB, no way to continue."
    exit
  fi
fi

if [ "$KEYID" == "" ]; then
  echo "[!] Can't get your keyid. Abort!"
  exit
fi

echo "[*] Public keyid is $KEYID"
if [ ! -d $HOME/.gnupg ]; then
  echo "[*] remake .gnupgdir"
  mkdir ~/.gnupg

  # this will recreate the trustdb and pubring files (but they will be empty)
  gpg --list-keys
fi

# at this point we should have a fresh gnupg dir and be ready for import.
gpg --import ~/pubkey/$KEYID-pub.asc
gpg --import ~/pubkey/sub-key-stubs.gpg

# we're on our own now. 
./finalize.expect

# Got it!
./done.sh

