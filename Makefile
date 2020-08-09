
ifndef env
# $(error env is not set)
	env ?= dev
endif

include config.$(env)
export

ifndef MAIN_STACK_NAME
	$(error MAIN_STACK_NAME is not set)
endif

ifndef BUCKET
	$(error BUCKET is not set)
endif

ifndef version
	export version := $(shell date +%Y%b%d-%H%M)
endif

# Filename for the CFT to deploy
export DEPLOY_PREFIX=deploy-packages
export TEMPLATE=cloudformation/Minecraft-Template.yaml
OUTPUT_TEMPLATE_PREFIX=Minecraft-Template-Transformed
OUTPUT_TEMPLATE=$(OUTPUT_TEMPLATE_PREFIX)-$(version).yaml
TEMPLATE_URL ?= https://s3.amazonaws.com/$(BUCKET)/$(DEPLOY_PREFIX)/$(OUTPUT_TEMPLATE)
CONFIG_PREFIX=config-files

export LAMBDA_PACKAGE=$(MAIN_STACK_NAME)-lambda-$(version).zip
export SKILL_PACKAGE=$(MAIN_STACK_NAME)-skill-$(version).zip


# List of all the functions deployed by this stack. Required for "make update" to work.
FUNCTIONS = $(MAIN_STACK_NAME)-alexa-handler

.PHONY: $(FUNCTIONS)

# Run all tests
test: cfn-validate
	cd lambda && $(MAKE) test

deps:
	cd lambda && $(MAKE) deps

skill:
	cd alexa && $(MAKE) package

#
# Deploy New Code Targets
#

# Deploy a fresh version of code
deploy: cft-validate package cft-deploy push-config

package: deps
	@aws cloudformation package --template-file $(TEMPLATE) --s3-bucket $(BUCKET) --s3-prefix $(DEPLOY_PREFIX)/transform --output-template-file cloudformation/$(OUTPUT_TEMPLATE)  --metadata build_ver=$(version)
	@aws s3 cp cloudformation/$(OUTPUT_TEMPLATE) s3://$(BUCKET)/$(DEPLOY_PREFIX)/
# 	rm cloudformation/$(OUTPUT_TEMPLATE)

cft-deploy: skill package
ifndef MANIFEST
	$(error MANIFEST is not set)
endif
	cft-deploy -m cloudformation/$(MANIFEST) --template-url $(TEMPLATE_URL) pTemplateURL=$(TEMPLATE_URL) pBucketName=$(BUCKET) pSkillPackage=$(DEPLOY_PREFIX)/$(SKILL_PACKAGE) --force


#
# Promote Existing Code Targets
#

# promote an existing stack to a new environment
# Assumes cross-account access to the lower environment's DEPLOY_PREFIX
promote: cft-promote push-config

cft-promote:
ifndef MANIFEST
	$(error MANIFEST is not set)
endif
ifndef template
	$(error template is not set)
endif
ifndef skill
	$(error skill is not set)
endif
	cft-deploy -m cloudformation/$(MANIFEST) --template-url $(template) pTemplateURL=$(template) pBucketName=$(BUCKET) pSkillPackage=$(skill) --force


#
# Testing & Cleanup Targets
#
# Validate all the CFTs. Inventory is so large it can only be validated from S3
cft-validate:
	cft-validate -t $(TEMPLATE)


# Clean up dev artifacts
clean:
	cd lambda && $(MAKE) clean
	cd alexa && $(MAKE) clean
	rm cloudformation/$(OUTPUT_TEMPLATE_PREFIX)*

pep8:
	cd lambda && $(MAKE) pep8

cft-validate-manifest: cft-validate
	cft-validate-manifest --region $(AWS_DEFAULT_REGION) -m cloudformation/$(MANIFEST) --template-url $(TEMPLATE_URL) pBucketName=$(BUCKET)

#
# Management Targets
#

# target to generate a manifest file. Only do this once
# we use a lowercase manifest to force the user to specify on the command line and not overwrite existing one
manifest:
ifndef manifest
	$(error manifest is not set)
endif
	cft-generate-manifest -t $(TEMPLATE) -m cloudformation/$(manifest) --stack-name $(MAIN_STACK_NAME) --region $(AWS_DEFAULT_REGION)

push-config:
	@aws s3 cp cloudformation/$(MANIFEST) s3://$(BUCKET)/${CONFIG_PREFIX}/$(MANIFEST)


#
# Rapid Development Targets
#
zipfile:
	cd lambda && $(MAKE) zipfile

# # Update the Lambda Code without modifying the CF Stack
update: zipfile $(FUNCTIONS)
	for f in $(FUNCTIONS) ; do \
	  aws lambda update-function-code --function-name $$f --zip-file fileb://lambda/$(LAMBDA_PACKAGE) ; \
	done

# Update one specific function. Called as "make fupdate function=<fillinstackprefix>-aws-inventory-ecs-inventory"
fupdate: zipfile
	aws lambda update-function-code --function-name $(function) --zip-file fileb://lambda/$(LAMBDA_PACKAGE) ; \

purge-logs:
	for f in $(FUNCTIONS) ; do \
	  aws logs delete-log-group --log-group-name /aws/lambda/$$f ; \
	done

expire-logs:
	for f in $(FUNCTIONS) ; do \
	  aws logs put-retention-policy --log-group-name /aws/lambda/$$f --retention-in-days 5 ; \
	done


