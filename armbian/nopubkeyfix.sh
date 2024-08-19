#!/bin/bash
# Simple Script to fix NO_PUBKEY
# by Richard Hanz Kalaw
# email scott_rk@yahoo.com
# web http://projectrk.com.ph
#
echo "Simple NO_PUBKEY Fix"
echo
echo "NOTE:"
echo "Copy the key right after the \"NO_PUBKEY XXXXXX\" where \"XXXXXX\" is the key"
read -p 'Input NO_PUBKEY: ' pubkey
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $pubkey
echo "Done... $pubkey fixed"
echo
date
