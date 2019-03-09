#!/bin/bash

# Creates a new server & world

source /etc/minecraft.conf

msm server create ${STACKNAME} && \
msm ${STACKNAME} jar minecraft && \
echo "msm-version=minecraft/1.7.0" >> /home/ec2-user/servers/${STACKNAME}/server.properties && \
echo eula=true > /home/ec2-user/servers/${STACKNAME}/eula.txt && \
msm ${STACKNAME} start