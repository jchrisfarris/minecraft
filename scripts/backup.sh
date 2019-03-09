#!/bin/bash

source /etc/minecraft.conf

/etc/init.d/msm $STACKNAME backup

# Copy to S3
aws --quiet s3 sync /home/ec2-user/archives/backups/$STACKNAME s3://$BUCKET/backups/$STACKNAME/
