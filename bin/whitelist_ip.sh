#!/bin/bash

STACKNAME=$1
IPADDR=$2
PORT=$3
if [ -z $IPADDR ] ; then
    echo "Usage: $0 <stackname> <ip> [port]"
    exit 1
fi

if [ -z $PORT ] ; then
    PORT=25565  # Minecraft port
fi

SG=`aws cloudformation describe-stacks --stack-name $STACKNAME --query 'Stacks[0].Outputs[?OutputKey==\`SecurityGroup\`].OutputValue' --output text`

echo "Adding $IPADDR to Security Group $SG for port $PORT"

aws ec2 authorize-security-group-ingress --group-id $SG --protocol tcp --port $PORT --cidr ${IPADDR}/32