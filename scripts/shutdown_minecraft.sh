#!/bin/bash

source /etc/minecraft.conf

/etc/init.d/msm $STACKNAME say "Server is shutting down in 5 minutes. Please wrap up and log off..."
sleep 300

/etc/init.d/msm $STACKNAME backup

# Copy to S3
aws --quiet s3 sync /home/ec2-user/archives/backups/$STACKNAME s3://$BUCKET/backups/$STACKNAME/

sudo halt -p
