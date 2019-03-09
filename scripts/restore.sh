#!/bin/bash

# Restores a backed up server from S3

# Load Config
source /etc/minecraft.conf

if [ -z $1 ] ; then
    S3OBJECT=$1
else
    # This should be the most recent.
    S3OBJECT=`aws s3 ls s3://$BUCKET/backups/${STACKNAME}/ | awk '{print $NF}' | sort | tail -1`
fi

# Stop the server if it's running
msm $STACKNAME stop

# Create the server dir if needed
mkdir -p /home/ec2-user/servers

# Copy the backup file down from S3
aws s3 cp --quiet s3://$BUCKET/backups/${STACKNAME}/$S3OBJECT /home/ec2-user/servers/$S3OBJECT
if [ $? -ne 0 ]; then
    echo "Error Downloading backup from S3. Aborting"
    exit 1
fi

# Unzip the file and cleanup
cd /home/ec2-user/servers
unzip -qo $S3OBJECT
rm $S3OBJECT

# Make sure ownership is all good.
chown -R ec2-user:ec2-user /home/ec2-user

# And now start the server
msm $STACKNAME start