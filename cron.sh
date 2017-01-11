#!/bin/bash
env > /env.txt

cat /env.txt /crontab.txt > /cron-jobs

chmod 644 /cron-jobs

crontab /cron-jobs

touch /var/log/cron.log

tail -f /var/log/cron.log &

cron -f
