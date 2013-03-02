#!/bin/sh -e
#
# File:
# Purpose:
#

cd $(dirname "$0"); . ./common.sh; cd ..

exit_if_nonroot

# build programs
for i in $ctf1_orig/code/level*; do
    test -f $i/Makefile && (cd $i; make)
done

# build extra programs
for i in $ctf1_append/levels/level*; do
    test -f $i/Makefile && (cd $i; make)
done

# create users
create_users0=/tmp/create-users.sh
create_users=$extract$create_users0
for i in 0 1 2 3 4 5 6; do
    pass=$(pwgen 8 1)
    echo "# level0$i"
    echo "adduser -s /bin/sh -u 110$i -D level0$i"
    echo "echo level0$i:$pass | chpasswd --md5"
    echo "echo $pass > /home/level0$i/.password"
    echo
done | tee $create_users

# add users to groups
for i in 0 1 2 3 4 5; do
    echo "addgroup level0$i level0$((i+1))"
done | tee -a $create_users

# set a password for tc user
tcpass=$(pwgen 8 1)
echo "echo tc:$tcpass | chpasswd --md5" | tee -a $create_users
echo $tcpass > $extract/home/tc/.password

# run create user script in chroot
chmod 755 $create_users
chroot $extract $create_users0
rm $create_users

# copy ctf1 files
mkdir -p $extract/levels/level00
rsync -av $ctf1_orig/code/level0? $extract/levels/
rsync -av $ctf1_append/* $extract/ --exclude '*.c'

# fix permissions
chmod 0750 $extract/home/level0?
chmod g-s $extract/home/level0?
chmod 0400 $extract/home/level0?/.password
chmod 0750 $extract/levels/level0?

# fix ownerships
chown -R 0.50 $extract/root
chown 0.50 $extract/levels

# create message files
for i in 0 1 2 3 4 5 6; do
    cat $ctf1_motd/banner.txt $ctf1_motd/level0$i.txt > $extract/home/level0$i/motd.txt
    echo clear >> $extract/home/level0$i/.profile
    echo 'cat ~/motd.txt' >> $extract/home/level0$i/.profile
done

# fix ownerships
for i in 0 1 2 3 4 5 6; do
    chown -R 110$i.110$i $extract/home/level0$i
    chown -R 110$i.110$i $extract/levels/level0$i
    test $i = 0 || chmod 4755 $extract/levels/level0$i/level0$i
done

# eof
