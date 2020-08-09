

# Static, not sure if needed??
PYTHON=python3
PIP=pip3

# Files are required when doing a make update
FILES=	alexa_skill.py \
		utils.py

JUNK=HISTORY.rst LICENSE NOTICE README.rst bin certifi requests chardet requests_aws4auth elasticsearch urllib3 idna mako markupsafe

DEPENDENCIES=ask_sdk_core ask_sdk_model ask_sdk_runtime bin boto3 botocore certifi chardet dateutil docutils idna jmespath requests s3transfer six.py urllib3

.PHONY:

package: test clean deps zipfile

#
# Lambda function management
#

clean:
	rm -rf __pycache__ *.zip *.dist-info $(DEPENDENCIES) $(JUNK)

# # Create the package Zip. Assumes all tests were done
zipfile:  $(FILES) $(DEPENDENCIES)
	zip -r $(LAMBDA_PACKAGE) $^


test: $(FILES)
	for f in $^; do $(PYTHON) -m py_compile $$f; if [ $$? -ne 0 ] ; then echo "$$f FAILS" ; exit 1; fi done

deps:
	$(PIP) install -r requirements.txt -t . --upgrade
