#!/bin/bash

#rsync parameters
src=/media/pi/wd_nas_4tb
dest=/media/pi/wd_nas_4tb_backup

#email parameters
sender=kimfamilydesktop26@gmail.com
recipient=paulkim26.pk@gmail.com
subject="Hard Drive Backup Summary"

#backup files
cd /home/pi/log/
start_epoch=$(date +%s)
echo "Starting backup..."
rsync -vru --delete --exclude '$RECYCLE.BIN' --exclude 'System Volume Information' $src $dest > rsync_log
end_epoch=$(date +%s)
echo "Backup complete."

#calculate duration
diff="$(($end_epoch - $start_epoch))"
hours=$(($diff / 3600))
minutes=$((($diff / 60) % 60))
seconds=$(($diff % 60))

#create log
log=$(date +%Y%m%d%H%M%S;).txt
echo "Backup Summary" > $log
echo "Start Time: $(date -d @$start_epoch)" >> $log
echo "End Time: $(date -d @$end_epoch)" >> $log
echo "Duration: ${hours}h ${minutes}m ${seconds}s" >> $log
echo "SYSTEM DISK USAGE==============================================" >> $log
df >> $log
echo "RSYNC SUMMARY==================================================" >> $log
cat rsync_log >> $log
echo "END OF LOG=====================================================" >> $log
rm rsync_log

#send email
echo "To: $recipient" > email.txt
echo "From: $recipient" >> email.txt
echo "Subject: $subject" >> email.txt
cat $log >> email.txt

cat email.txt | msmtp $recipient
echo "Email sent to: $recipient"
rm email.txt
