#!/bin/bash

STACKNAME=$1

if [ -z $STACKNAME ] ; then
    echo "Usage: $0 <stackname>"
    exit 1
fi

source config.$STACKNAME

A='{"Server":["'
B=$STACKNAME
C='"],"Command":["start"]}'
PARAM="${A}${B}${C}"

aws ssm send-command --document-name "$MSMCOMMAND" --document-version "\$LATEST" --targets "Key=instanceids,Values=$INSTANCEID" --parameters $PARAM --timeout-seconds 600 --max-concurrency "50" --max-errors "0" --output-s3-bucket-name "$BUCKET" --output-s3-key-prefix "ssm_commands" --cloud-watch-output-config '{"CloudWatchOutputEnabled":false}'