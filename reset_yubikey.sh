#!/bin/bash
#
# nuke the card config from orbit.
#


gpg --card-status

if [ $? != 0 ]; then
  echo "can't talk to your card. remove and reinsert."
fi

cat <<EOF 

If this fails with IPC errors, remove and reinsert the card
and run the script again. 

If IPC errors continue, Run gpg-card edit to create the gpg dir and
run the script again.

EOF

echo -n "Press RETURN to reset the card: "
read INPUT

/usr/local/MacGPG2/bin/gpg-connect-agent -r reset_yubikey.txt

echo "REMOVE AND REPLACE THE YUBIKEY NOW."




