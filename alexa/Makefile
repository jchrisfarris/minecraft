

# Static, not sure if needed??
PYTHON=python3
PIP=pip3

# Files are required when doing a make update
FILES=	interactionModels/custom/en-US.json \
		assets \
		skill.json


.PHONY:

package: clean transform zipfile upload

#
# Lambda function management
#

clean:
	rm -rf  *.zip interactionModels/custom/en-US.json

transform:
ifndef INVOCATION
	$(error INVOCATION is not set)
endif
	cat interactionModels/custom/en-US-TEMPLATE.json | jq '.interactionModel.languageModel.invocationName=$(INVOCATION)' > interactionModels/custom/en-US.json

# # Create the package Zip. Assumes all tests were done
zipfile:  $(FILES)
	zip -r $(SKILL_PACKAGE) $^

upload:
	@aws s3 cp $(SKILL_PACKAGE) s3://${BUCKET}/$(DEPLOY_PREFIX)/$(SKILL_PACKAGE)