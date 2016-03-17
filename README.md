# personal-linux-config

after pulling the repo do the followings as root:

su
groupadd -f sudo
groupadd -f users
usermod -a -G users,sudo faham
sed  -i "s/^# %sudo   ALL=(ALL) ALL$/%sudo   ALL=(ALL) ALL/" /etc/sudoers

then run the following as faham:
~/bin/config-machine
