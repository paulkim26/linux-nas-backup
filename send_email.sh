#!/bin/bash

sender=kimfamilydesktop26@gmail.com
recipient=paulkim26.pk@gmail.com
subject="Email Test using MSMTP from File"
message="This is the body of the message. This is the second line."

echo "To: $recipient" > email.txt
echo "From: $recipient" >> email.txt
echo "Subject: $subject" >> email.txt
echo $message >> email.txt

cat email.txt | msmtp $recipient
rm email.txt