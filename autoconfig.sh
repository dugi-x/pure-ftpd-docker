#!/bin/bash

PASSWD_FILE="/etc/pure-ftpd/pureftpd.passwd"

for d in /home/ftpusers/*; do

    if [[ -d $d ]]; then

        _UID=$(stat -c "%u" $d)
        _GID=$(stat -c "%g" $d)

        mkdir -p $d/conf/ftpd
        touch $d/conf/ftpd/pureftpd.passwd
        touch $d/conf/ftpd/pureftpd.useradd
        touch $d/conf/ftpd/pureftpd.userdel

        #userdel
        for USERPASS in $(cat $d/conf/ftpd/pureftpd.userdel); do
            user_name=$(awk -F: '{print $1}' <<< $USERPASS)
            pure-pw userdel  "$user_name" -f "$d/conf/ftpd/pureftpd.passwd"
        done
        echo "" > $d/conf/ftpd/pureftpd.userdel

        #useradd
        for USERPASS in $(cat $d/conf/ftpd/pureftpd.useradd); do
            user_name=$(awk -F: '{print $1}' <<< $USERPASS)
            pass_temp="$(mktemp)"
            awk -F: '{print $2"\n"$2}' <<< $USERPASS > $pass_temp
            pure-pw useradd  "$user_name" -f "$d/conf/ftpd/pureftpd.passwd" -d "$d/public_html" -u $_UID -g $_GID < "$pass_temp"
            rm -f $pass_temp
        done
        echo "" > $d/conf/ftpd/pureftpd.useradd

        #normalize local.passwd and push to global.passwd
        for USERPASS in $(awk -F: '{print $1":"$2}' $d/conf/ftpd/pureftpd.passwd); do
           
            echo "$USERPASS:$_UID:$_GID::$d/public_html./::::::::::::" >> $PASSWD_FILE
        done
        
    fi
done

#show and build
pure-pw list
pure-pw mkdb /etc/pure-ftpd/pureftpd.pdb -f $PASSWD_FILE

