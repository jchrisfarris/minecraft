#!/bin/bash

# Script to update the scripts from Github

REPOBASE="https://raw.githubusercontent.com/jchrisfarris/minecraft/master/scripts"
SCRIPTS="download_scripts.sh backup.sh restore.sh new_world.sh restart_minecraft.sh shutdown_minecraft.sh"
SCRIPT_HOME="/home/ec2-user/scripts"

if [ ! -d $SCRIPT_HOME ] ; then
    mkdir -p $SCRIPT_HOME
fi

for s in $SCRIPTS ; do
    curl -s ${REPOBASE}/${s} > ${SCRIPT_HOME}/${s}
    chmod 755 ${SCRIPT_HOME}/${s}
done