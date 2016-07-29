#!/bin/bash
#
# Final message. 
#

cat <<EOF

We're done!

You now have the following: 

- A backup of your keys and GPG setup in ~/.gnupg
- Your public key and private key stubs in $HOME/pubkey

Things to do now:

1. Copy your public key and private key stubs to any additional
   machines you want to use your yubikey from. Import these keys into
   GPG and yubikey will just work on those systems. 

2. Backup the ~/USB directory to an encrypted USB drive.

3. Secure-erase the ~/USB directory from this system (using "srm -rf
   ~/USB").  It contains the last copy of your private key.

4. Set up SSH.
   (or run "./setup_ssh.sh" to install fresh keys.)
      
EOF
