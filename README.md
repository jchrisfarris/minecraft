# AWS Hosted Minecraft server with Alexa control

This repo contains a CloudFormation template, scripts and an Alexa skill to manage the instance

It deploys:

1. t3.small EC2 Instance, with security group, IAM Instance Profile, etc.
2. EIP static IP + (optional) Route53 entry
3. SSM Documents to manage [msm](https://github.com/msmhq/msm) and to run scripts on the server
4. Lambda to process the commands
5. An Alexa Skill and a Lambda to process the Alexa intents
6. CloudWatch Scheduled Events to turn the server on after school and off at bedtime

The `scripts` directory contains several scripts to be run on the minecraft server:

* **backup.sh** - Trigger a minecraft server backup and push to S3
* **download_scripts.sh** - Downloads all the scripts in this directory. Called by Instance MetaData
* **install.sh** - Install script, also called by Instance MetaData
* **new_world.sh** - Configure a new server and create a world
* **restart_minecraft.sh** - Script to restart the minecraft server, one of the Alexa intents
* **restore.sh** - Gather backup from S3 and drop it into ec2-user
* **shutdown_minecraft.sh** - Script to shutdown the server cleanly. It announces a 5 minute warning, does a backup, the stops the server for the night.


## Costs

A t2.small costs $0.0208 per hour. \
A detached EIP costs "$0.005 per Elastic IP address not associated with a running instance per hour on a pro rata basis" \
With an estimate of 720 hrs in a month, if the instance is live 8 hours a day \
EC2 Costs: (720/3) * 0.0208 = $4.992 \
EIP Costs: (720/3) * 2 * 0.005 = $2.40 \
Total = $7.39

Lambda invocation, SSM commands, the Alexa Skill, etc are all well within the free tier.

## Alexa Commands

1. *Alexa tell minecraft server to stop*
1. *Alexa tell minecraft server to start*
1. *Alexa tell minecraft server to restart*


## Installation

1. Install [cftdeploy](https://pypi.org/project/cftdeploy/) to deploy the serverless stack.
2. Create an S3 bucket to store stuff
3. Create a config.ENV file (where ENV is an identifier):
```
MAIN_STACK_NAME=minecraft
BUCKET=NAME-OF-S3-Bucket
MANIFEST=minecraft-Manifest.yaml
INVOCATION="NAMEs minecraft server"
```
Avoid apostrophes in INVOCATION
4. `make manifest env=ENV manifest=minecraft-Manifest.yaml`
5. Edit the Manifest file. Remove the `LocalTemplate` line and set the other Parameters accordingly.
5. make deploy env=ENV


### Alexa Deploy Secret

Creating the Skill requires you to have a [Amazon Developer account](https://developer.amazon.com/) (which is separate from your AWS account).

1. Then create a [Login with Amazon Profile](https://developer.amazon.com/loginwithamazon/console/site/lwa/overview.html)
1. Vendor ID from this URL: https://developer.amazon.com/mycid.html
2. ClientID & Secret from here: https://developer.amazon.com/loginwithamazon/console/site/lwa/overview.html
3. refresh token:
	1. Install the [ASK CLI tool](https://developer.amazon.com/en-US/docs/alexa/smapi/quick-start-alexa-skills-kit-command-line-interface.html)
	2. Run `ask util generate-lwa-tokens --scope alexa::ask:skills:readwrite`
4. Create a secret in AWS Secrets Manager with the values from the above:

Json should look like:

```json
{
  "client_id": "amzn1.application-oa2-client.REDACTED",
  "client_secret": "REDACTED",
  "refresh_token": "Atzr|BIG-LOG-SESSION-TOKEN-BLAH",
  "vendor_id": "M1C39XXXXXXXG"
}
```

### Bugs

Due to a bug, the Lambda Override lines in the CFT must be disabled when the skill is first created:
```yaml
            apis:
              custom:
                endpoint:
                  uri: !GetAtt AlexaSkillHandlerFunction.Arn
```

The Alexa Skill resource will validate that the skill can invoke the Lambda function. However until the skill is created, the Lambda invocation role doesn't have the skill ID. You can create the skill w/o the custom endpoint, then once the skill ID is on the lambda function, update the skill to push the custom endpoint.