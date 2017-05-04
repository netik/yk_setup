# yk_setup

Takes a brand new Yubikey NEO and configures it for U2F, GPG, and SSH authentication.

Order of scripts is as follows:

1. Run ./yubikey_setup.sh
2. Run ./move_keys_to_card.sh
3. Run ./finalize.sh
4. Run ./setup_ssh


## GPG agent and El Capitan

The fouth step will be very tricky on el Capitan machines. 
Apple runs their own gpg-agent. We must disable this for MacGPG2 to run, because Apple's agent does not have support for Yubikey. 

However, this OS uses system integrity protection and you cannot disable the native GPG agent without some work.

I used to recommend that you disable SIP and then get MacGPG to take over the work. I no longer recommend this as having SIP is useful to protect your machine. 

The best thing you can do now is run Mac GPG alongside the system GPG agent, and repoint your GPG_AGENT to the Mac GPG Socket instead of the system socket.

## Starting Over

If everything fails, you can run ./reset_yubikey.sh to reset the card, and then remove your ~/USB and ~/.gnupg dirs.
Obviously this is a highly destructive procedure.

