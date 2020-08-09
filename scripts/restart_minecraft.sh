#!/bin/bash

source /etc/minecraft.conf

/etc/init.d/msm $STACKNAME restart

ps -ax | grep SCREEN | grep -v grep
if [ $? -ne 0 ] ; then
	echo "SCREEN process is not running"
fi