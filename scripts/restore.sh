#!/bin/bash

# Restores a backed up world from S3

source /etc/minecraft.conf

msm $SERVER stop

mkdir -p /home/$USER/servers

aws s3 cp s3://$S3BUCKET/$S3OBJECT /home/$USER/servers/restore.zip

cd /home/$USER/servers

unzip -q restore.zip

chown -R $USER:$USER /home/$USER

msm $SERVER start