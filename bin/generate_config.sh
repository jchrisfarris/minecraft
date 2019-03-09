#!/bin/bash

STACKNAME=$1

if [ -z $STACKNAME ] ; then
    echo "Usage: $0 <stackname>"
    exit 1
fi

aws cloudformation describe-stacks --stack-name $STACKNAME --query 'Stacks[0].Outputs[]' --output text | sed "s/$(printf '\t')/=/g"