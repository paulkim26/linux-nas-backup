========================================
Raspberry Pi NAS Setup
Date: March 14, 2020

========================================
USEFUL COMMANDS

lsblk
>check all mounts

fdisk -l
>check all mounts

========================================
MOUNTING

Source: https://www.tecmint.com/how-do-i-access-or-mount-windows-ntfs-partition-in-linux/

Install ntfs-3g to allow rw access to NTFS file systems.

fdisk -l
>view available partitions
ie. /dev/sda1

mkdir /mnt/<drive>
>create directory to represent mount point

mount -t ntfs-3g /dev/sda1 /mnt/<drive>
>mount drive by system assigned name (order of discovery) (DON'T USE THIS)

mount -L "<partition label>" /mnt/<drive>
>mount drive by label
>drive will now be accessible @ /mnt/<drive>

sudo nano /etc/fstab
>modify to have permanent mount at startup
>add the following:

LABEL=<label>     /mnt/<drive>    ntfs-3g   defaults 0 0


To unmount:
umount /mnt/<drive>

----------------------------------------
SAMBA setup (NAS)

Source: https://pimylifeup.com/raspberry-pi-samba/

sudo apt-get install samba samba-common-bin
>install SAMBA

sudo nano /etc/samba/smb.conf
>modify the SAMBA configuration file, adding the following text at the bottom:

[<share name>]
path = <directory>
writeable = yes
create mask = 0777
directory mask = 0777
public = no

sudo smbpasswd -a <samba user, ie. pi>
>setup a SAMBA user and password

sudo systemctl restart smbd
>restart the SAMBA service

share will be visible from windows
ie. \\192.168.1.111\<share name>
----------------------------------------
EMAIL

Source: https://hostpresto.com/community/tutorials/how-to-send-email-from-the-command-line-with-msmtp-and-mutt/
More sources:
https://wiki.alpinelinux.org/wiki/Relay_email_to_gmail_(msmtp,_mailx,_sendmail
https://www.emanueletessore.com/how-to-configure-msmtp-as-a-gmail-relay-on-ubuntu-server/
https://afreshcloud.com/sysadmin/send-server-reports-by-email-with-msmtp-and-gmail-smtp

Note: gmail account should have the "Allow less secure apps: " toggle set to ON. Otherwise it will complain that the username and password were not accepted.
https://myaccount.google.com/lesssecureapps

sudo apt-get -y install msmtp
>install msmtp

dpkg -l | grep ca-certificates
>confirm certificates are present

sudo apt-get -y install ca-certificates
>if no certificates, install

/etc/msmtprc
>create a MSMTP configuration and add the following:
++++++++++++++++++++++++++++++++++++++++
# Set default values for all following accounts.
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
syslog         on

# Gmail
account        gmail
host           smtp.gmail.com
port           587
from           <gmail address>
user           <gmail address>
password       <gmail password>

# Set a default account
account default : gmail
aliases        /etc/aliases
++++++++++++++++++++++++++++++++++++++++

echo "Hello this is sending email using msmtp" | msmtp recipent@domain.com

echo "Hello this is sending email using msmtp" | msmtp -a gmail recipent@domain.com
>specifies a configuration (gmail)

echo "Subject: Hello this is subject" | msmtp recipient@domain.com
>send w/ subject

printf "To: @domain.comnFrom: @gmail.comnSubject: Email Test Using MSMTPnnHello there. This is email test from MSMTP." | msmtp recipient@domain.com
>a complete email

++++++++++++++++++++++++++++++++++++++++
To: @gmail.com
From: @gmail.com
Subject: Email Test using MSMTP from File
Hi,
This is an email test from file.
++++++++++++++++++++++++++++++++++++++++
cat email.txt | msmtp -a default recipient@domain.com

----------------------------------------
RSYNC

rsync -vr --delete --exclude '$RECYCLE.BIN' --exclude 'System Volume Information' <src path ie. /media/pi/mydrive> <src path ie. /media/pi/mybackup>
> -v		verbose output
> -r		retains file directory structure (?)
> --delete	removes files in destination directory that don't exist in source anymore
> --exclude	excludes directories

========================================