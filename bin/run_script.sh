#!/bin/bash

STACKNAME=$1

if [ -z $STACKNAME ] ; then
    echo "Usage: $0 <stackname> <command>"
    exit 1
fi

source config.$STACKNAME

COMMAND=$2
if [ -z $COMMAND ] ; then
    echo "Usage: $0 <stackname> <command>"
    exit 1
fi

A='{"Command":["'
B=$COMMAND
C='"]}'
PARAM="${A}${B}${C}"

aws ssm send-command --document-name "$EXECSCRIPT" --document-version "\$LATEST" --targets "Key=instanceids,Values=$INSTANCEID" --parameters $PARAM --timeout-seconds 600 --max-concurrency "50" --max-errors "0" --output-s3-bucket-name "$BUCKET" --output-s3-key-prefix "ssm_commands" --cloud-watch-output-config '{"CloudWatchOutputEnabled":false}'