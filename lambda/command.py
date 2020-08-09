import json
import boto3
from botocore.exceptions import ClientError
import sys
import os

import logging
logger = logging.getLogger()
logger.setLevel(getattr(logging, os.getenv('LOG_LEVEL', default='INFO')))
logging.getLogger('botocore').setLevel(logging.WARNING)
logging.getLogger('boto3').setLevel(logging.WARNING)
logging.getLogger('urllib3').setLevel(logging.WARNING)

def lambda_handler(event, context):
    # logger.debug("Received event: " + json.dumps(event, sort_keys=True))
    # message = json.loads(event['Records'][0]['Sns']['Message'])
    message = event
    logger.info("Received message: " + json.dumps(message, sort_keys=True))

    client = boto3.client('ec2')
    instance_id = os.environ['INSTANCE_ID']

    if message['command'] == "stop":
      # TODO Make this an cleaner SSM shutdown command
      logger.info(f"Stopping Instance {os.environ['INSTANCE_ID']}")
      command = "shutdown_minecraft.sh"
      response = ssm_send_command(command)
      logger.debug(response)
    elif message['command'] == "restart":
      # TODO Make this an cleaner SSM shutdown command
      logger.info(f"Restarting Minecraft on Instance {os.environ['INSTANCE_ID']}")
      command = "restart_minecraft.sh"
      response = ssm_send_command(command)
      logger.debug(response)
    elif message['command'] == "start":
      logger.info(f"Starting Instance {os.environ['INSTANCE_ID']}")
      response = client.start_instances(InstanceIds=[instance_id])
      logger.debug(response)
    else:
      logger.error(f"Invalid Command {message['command']}")
### End Of Function ###

def ssm_send_command(command):

  client = boto3.client('ssm')
  response = client.send_command(
    InstanceIds=[os.environ['INSTANCE_ID']],
    DocumentName=os.environ['EXECSCRIPT'],
    DocumentVersion='$LATEST',
    TimeoutSeconds=600,
    Parameters={
        'Command': [command]
    },
    OutputS3BucketName=os.environ['BUCKET'],
    OutputS3KeyPrefix='ssm_commands',
    MaxConcurrency='50',
    MaxErrors='0',
    CloudWatchOutputConfig={
        'CloudWatchOutputEnabled': False
    }
  )
  return(response)