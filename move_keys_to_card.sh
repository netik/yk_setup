#!/bin/bash
#
# move_keys_to_card.sh 
# Move gpg keys to your yubikey.
#
# J. Adams <jna@bolt.me> 
# 7/27/2016
#
# Note: can only be run after yubikey_setup.sh finishes!
# Run me second!
#

export USBTMP=${HOME}/USB
MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TODAY=`date +'%Y-%m-%d'`

#
# This script can only be run after yubikey_setup.sh finishes. 
# at this point we should have the gpg dir built, the revocation 

if [ ! -f ~/Downloads/ykpers-1.17.3-mac.zip ]; then 
  echo "[*] Download yubikey tools - ykpers"
  ( cd ~/Downloads; curl -O https://developers.yubico.com/yubikey-personalization/Releases/ykpers-1.17.3-mac.zip )
fi

if [ ! -f /usr/local/bin/ykpersonalize ]; then
  echo "[*] Unpack yubikey tools to /usr/local - please enter your password if prompted by sudo."
  cd /usr/local/
  sudo /usr/bin/unzip ~/Downloads/ykpers-1.17.3-mac.zip
fi

echo "[*] Set eject flag to support OTP and CCID on Yubikey."
echo "y" | ykpersonalize -m82

cat <<EOF

[*] Move GPG keys to yubikey. 

If you get asked for a PIN, on a new Yubikey, The factory
default PINs are 123456 (user) and 12345678 (admin).

EOF

# normally here we'd reimport the secret key, but I'm not going to do
# that because we just made them.

${MYDIR}/move_keys.expect

# and export out stub 
gpg -a --export-secret-subkeys > $HOME/pubkey/sub-key-stubs.gpg

echo "make sure everything is ok and then run finalize.sh..."





