#!/bin/bash
#docker run -it --rm --name ftpd -e PUBLICHOST=192.168.1.122 -p=21:21 -p=30000-30009:30000-30009 dugi/pure-ftpd
#docker run -it --rm --name ftpd -e PUBLICHOST=192.168.1.122 -e AUTOCONFIG=1 -p=21:21 -p=30000-30009:30000-30009 -v /home:/home/ftpusers dugi/pure-ftpd

if [ "$AUTOCONFIG" -eq 1 ]; then
    source /autoconfig.sh
else
    pure-pw mkdb /etc/pure-ftpd/pureftpd.pdb -f /etc/pure-ftpd/passwd/pureftpd.passwd

    PASSWD_FILE="/etc/pure-ftpd/passwd/pureftpd.passwd"
    FTP_USER_NAME="bob"
    FTP_USER_HOME="/home/ftpusers/bob"
    FTP_USER_PASS="123456"

    mkdir -p "$FTP_USER_HOME"
    chown 99 "$FTP_USER_HOME"

    PWD_FILE="$(mktemp)"
    echo "$FTP_USER_PASS
$FTP_USER_PASS" > "$PWD_FILE"

    pure-pw useradd "$FTP_USER_NAME" -f "$PASSWD_FILE" -m -d "$FTP_USER_HOME" -u 99 -g 99 < "$PWD_FILE"
    rm "$PWD_FILE"
fi



exec "$@"