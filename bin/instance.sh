#!/bin/bash

STACKNAME=$1
if [ -z $STACKNAME ] ; then
    echo "Usage: $0 <stackname> <command>"
    exit 1
fi

source config.$STACKNAME

COMMAND=$2
if [ -z $COMMAND ] ; then
    echo "Usage: $0 <stackname> <start|stop>"
    exit 1
fi

if [ $COMMAND == "start" ] ; then
    ec2_command="start-instances"
elif [ $COMMAND == "stop" ] ; then
    ec2_command="stop-instances"
else
    echo "Invalid command: $COMMAND. Aborting..."
    exit 1
fi

aws ec2 $ec2_command --instance-ids $INSTANCEID
