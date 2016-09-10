#!/bin/bash

# No salt is needed for decryption.
PASS_FIXED=<your-passphrase>

# Error messages are redirect to /dev/null.
openssl enc -d -base64 -aes-256-ecb -k $PASS_FIXED -in "$1" 2> /dev/null || cat "$1"
