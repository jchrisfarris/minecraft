
ifndef STACK_NAME
# $(error env is not set)
	STACK_NAME ?= minecraft
endif

ifdef CONFIG
	include $(CONFIG)
	export
else
	include config.$(STACK_NAME)
	export
endif

ifndef BUCKET
	$(error BUCKET is not set)
endif

ifndef version
	export version := $(shell date +%Y%b%d-%H%M)
endif


# Filename for the CFT to deploy
export STACK_TEMPLATE=cloudformation/Minecraft-Template.yaml

# Name of the Zip file with all the function code and dependencies
export LAMBDA_PACKAGE=$(STACK_NAME)-lambda-$(version).zip

# Name of the manifest file.
export manifest=cloudformation/$(STACK_NAME)-Manifest.yaml

# location in the Antiope bucket where we drop lambda-packages
export OBJECT_KEY=deploy-packages/$(LAMBDA_PACKAGE)

# For uploading CFT to S3
export TEMPLATE_KEY ?= deploy-packages/$(STACK_NAME)-Template-$(version).yaml
export TEMPLATE_URL ?= https://s3.amazonaws.com/$(BUCKET)/$(TEMPLATE_KEY)

# List of all the functions deployed by this stack. Required for "make update" to work.
FUNCTIONS = $(STACK_NAME)-pull-organization-data

.PHONY: $(FUNCTIONS)

# Run all tests
test: cfn-validate
	cd lambda && $(MAKE) test

# Do everything
deploy: cfn-deploy

clean:
	cd lambda && $(MAKE) clean

#
# Cloudformation Targets
#

manifest:
	deploy_stack.rb -g $(STACK_TEMPLATE) > $(manifest)

# Upload template to S3
cfn-upload: $(STACK_TEMPLATE)
	aws s3 cp $(STACK_TEMPLATE) s3://$(BUCKET)/$(TEMPLATE_KEY)

# Validate the template
cfn-validate: $(STACK_TEMPLATE)
	aws cloudformation validate-template --region $(AWS_DEFAULT_REGION) --template-body file://$(STACK_TEMPLATE)

# Deploy the stack
cfn-deploy: cfn-validate cfn-upload $(manifest)
	deploy_stack.rb -m $(manifest) --template-url $(TEMPLATE_URL) pLambdaZipFile=$(OBJECT_KEY) pBucketName=$(BUCKET)  --force
	./bin/generate_config.sh $(STACK_NAME) > config.$(STACK_NAME)

#
# Lambda Targets
#
package:
	cd lambda && $(MAKE) package

zipfile:
	cd lambda && $(MAKE) zipfile

upload: package
	aws s3 cp lambda/$(LAMBDA_PACKAGE) s3://$(BUCKET)/$(OBJECT_KEY)

# # Update the Lambda Code without modifying the CF Stack
update: package $(FUNCTIONS)
	for f in $(FUNCTIONS) ; do \
	  aws lambda update-function-code --function-name $$f --zip-file fileb://lambda/$(LAMBDA_PACKAGE) ; \
	done

# Update one specific function. Called as "make fupdate function=<fillinstackprefix>-aws-inventory-ecs-inventory"
fupdate: zipfile
	aws lambda update-function-code --function-name $(function) --zip-file fileb://lambda/$(LAMBDA_PACKAGE) ; \

#
# Management Targets
#

purge-logs:
	for f in $(FUNCTIONS) ; do \
	  aws logs delete-log-group --log-group-name /aws/lambda/$$f ; \
	done

expire-logs:
	for f in $(FUNCTIONS) ; do \
	  aws logs put-retention-policy --log-group-name /aws/lambda/$$f --retention-in-days 5 ; \
	done
