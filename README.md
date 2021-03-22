# linux-nas-backup

## Introduction
A backup script for a Linux based NAS server to:
1. Backup an external drive to a secondary drive.
2. Send an email notification to the owner upon completion.

## Setup
This script has been written for use with the following NAS server configuration:
- 1x Raspberry Pi 3 running Raspbian Pi OS (the NAS server)
- 1x Primary External Hard Drive
- 1x Secondary External Hard Drive (of equal or greater capacity to the primary drive)
- A Windows client computer to connect to the NAS
- The [Samba](https://www.samba.org/) SMB networking protocol to provide file sharing for windows systems
- The [msmtp](https://marlam.de/msmtp/) SMTP client to send email notifications

### Preparing the hard drives
1. Format the 2 hard drives using the `NTFS` file system.
2. (optional) Load the primary hard drive with data.

### Preparing the Raspberry Pi
3. Install the latest version of Raspbian Pi OS.

### Mount the hard drives
4. Connect the two hard drives to the Raspberry Pi via the USB ports.
5. Install the `ntfs-3g` package to allow for read/write access to the NTFS file systems (see: [How Do I Access or Mount Windows/USB NTFS Partition in RHEL/CentOS/Fedora](https://www.tecmint.com/how-do-i-access-or-mount-windows-ntfs-partition-in-linux/)).
6. Create a directory to represent the primary drive's mount point.
```
mkdir /mnt/<drive>
```
7. Mount the primary drive, specifying the partition label in the command below. The drive will be accessible via the mount point `/mnt/<drive>`. Note: this mount point will not persist when the OS powers off.
```
mount -L "<partition label>" -t ntfs-3g /mnt/<drive>
```
8. Open the fstab file systems table for editing.
```
sudo nano /etc/fstab
```
9. Append the following line to this file:
```
LABEL=<label>     /mnt/<drive>    ntfs-3g   defaults 0 0
```
10. Repeat steps 6-9 for the secondary drive.

### Setting up the Samba share
see: [How to Setup a Raspberry Pi Samba Server](https://pimylifeup.com/raspberry-pi-samba/)
11. Install Samba.
```
sudo apt-get install samba samba-common-bin
```
12. Open the Samba configuration file for editing.
```
sudo nano /etc/samba/smb.conf
```
13. Append the following block of text at the bottom, replacing the <> fields:
```
[<share name>]
path = <directory>
writeable = yes
create mask = 0777
directory mask = 0777
public = no
```
14. Setup a Samba user and password.
```
sudo smbpasswd -a <samba user, ie. pi>
```
15. Restart the Samba service.
```
sudo systemctl restart smbd
```
16. The Samba share should now be visible from the Windows client.
```
ie. \\192.168.1.111\<share name>
```

### Set up the email service

Sources:
- https://hostpresto.com/community/tutorials/how-to-send-email-from-the-command-line-with-msmtp-and-mutt/
- https://wiki.alpinelinux.org/wiki/Relay_email_to_gmail_(msmtp,_mailx,_sendmail
- https://www.emanueletessore.com/how-to-configure-msmtp-as-a-gmail-relay-on-ubuntu-server/
- https://afreshcloud.com/sysadmin/send-server-reports-by-email-with-msmtp-and-gmail-smtp

17. Prepare an email account to use as the sender for the automatic notifications.
Note: Gmail accounts should have the `Allow less secure apps` toggle set to `ON`. Otherwise, the process will complain that the username and password were not accepted during the authentication process (see: https://myaccount.google.com/lesssecureapps).

18. Install the `msmtp` package.
```
sudo apt-get -y install msmtp
```
19. Confirm certificates are present on the local OS.
```
dpkg -l | grep ca-certificates
```
20. If they are not present, install the certificates.
```
sudo apt-get -y install ca-certificates
```
21. Create a MSMTP configuration at `/etc/msmtprc` and add the following lines:
```
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
```

## Run Backup Script
Execute the `backup_drive.sh` script to perform the backup process. The execution can be executed automatically using a scheduling tool such as crontab.

## Reference

### Mounting Drives
| Command | Description |
| - | - |
| `lsblk` | Check all mounted drives. |
| `fdisk` | Check all mounted drives. |
| `umount /mnt/<drive>` | Unmount a drive. 

### Test MSMTP Commands

Send an email with a body to a recipient.
```
echo "Hello this is sending email using msmtp" | msmtp recipent@domain.com
```

Send an email with a body to a recipient while specification a configuration (gmail):
```
echo "Hello this is sending email using msmtp" | msmtp -a gmail recipent@domain.com
```

Send an email with a subject line:
```
echo "Subject: Hello this is the subject" | msmtp recipient@domain.com
```

Send a complete email:
```
printf "To: @domain.comnFrom: @gmail.comnSubject: Email Test Using MSMTPnnHello there. This is email test from MSMTP." | msmtp recipient@domain.com
```

Send a complete email from a saved text file:
```
cat email.txt | msmtp -a default recipient@domain.com
```
