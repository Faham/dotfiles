#!/bin/bash

SALT_FIXED=<your-salt> # 24 or less hex characters
PASS_FIXED=<your-passphrase>

openssl enc -base64 -aes-256-ecb -S $SALT_FIXED -k $PASS_FIXED
