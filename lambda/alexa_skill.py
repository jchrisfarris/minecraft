# -*- coding: utf-8 -*-

# This sample demonstrates handling intents from an Alexa skill using the Alexa Skills Kit SDK for Python.
# Please visit https://alexa.design/cookbook for additional examples on implementing slots, dialog management,
# session persistence, api calls, and more.
# This sample is built using the handler classes approach in skill builder.
import boto3
from botocore.exceptions import ClientError
import json
import os

import ask_sdk_core.utils as ask_utils
from ask_sdk_core.skill_builder import SkillBuilder
from ask_sdk_core.dispatch_components import AbstractRequestHandler
from ask_sdk_core.dispatch_components import AbstractExceptionHandler
from ask_sdk_core.handler_input import HandlerInput
from ask_sdk_model import Response
from ask_sdk_model import ui


import logging
logger = logging.getLogger()
logger.setLevel(getattr(logging, os.getenv('LOG_LEVEL', default='INFO')))
logging.getLogger('botocore').setLevel(logging.WARNING)
logging.getLogger('boto3').setLevel(logging.WARNING)
logging.getLogger('urllib3').setLevel(logging.WARNING)


# Initialize the Skill class so we can register our handler/intents as we write.
# The SkillBuilder object acts as the entry point for your skill, routing all request and response
# payloads to the handlers above. Make sure any new handlers or interceptors you've
# defined are included below. The order matters - they're processed top to bottom.

sb = SkillBuilder()

def invoke_control_lambda(payload):
    client = boto3.client('lambda')
    response = client.invoke(
        FunctionName=os.environ['CONTROL_LAMBDA'],
        InvocationType='RequestResponse',
        Payload=json.dumps(payload)
    )
    if response['StatusCode'] == 200:
        return(True)
    else:
        logger.error(f"Error invoking {json.dumps(payload)} for {os.environ['CONTROL_LAMBDA']}: {response['FunctionError']}")
        return(False)


# Start the Server
class StartServerIntentHandler(AbstractRequestHandler):
    """Handler for Hello World Intent."""
    def can_handle(self, handler_input):
        # type: (HandlerInput) -> bool
        return ask_utils.is_intent_name("StartServer")(handler_input)

    def handle(self, handler_input):
        # type: (HandlerInput) -> Response
        # Do stuff
        payload = {"command": "start"}
        if invoke_control_lambda(payload) is True:
            speak_output = "Starting up the Server!"
            card_text = f"Starting Minecraft Server {os.environ['INSTANCE_ID']} at {os.environ['SERVER_FQDN']}"
        else:
            speak_output = "Error attempting to start the Server!"
            card_text = f"Error attempting to start the Server {os.environ['INSTANCE_ID']} at {os.environ['SERVER_FQDN']}"

        return (
            handler_input.response_builder
                .speak(speak_output)
                .set_card(
                        ui.StandardCard(
                            title=speak_output,
                            text=card_text,
                            # image=ui.Image(
                            #     small_image_url="<Small Image URL>",
                            #     large_image_url="<Large Image URL>"
                            # )
                        )
                    )
                # .ask("add a reprompt if you want to keep the session open for the user to respond")
                .response
        )
sb.add_request_handler(StartServerIntentHandler())

# Start the Server
class StopServerIntentHandler(AbstractRequestHandler):
    """Handler for Hello World Intent."""
    def can_handle(self, handler_input):
        # type: (HandlerInput) -> bool
        return ask_utils.is_intent_name("StopServer")(handler_input)

    def handle(self, handler_input):
        # type: (HandlerInput) -> Response

        # Do stuff
        payload = {"command": "stop"}
        if invoke_control_lambda(payload) is True:
            speak_output = "Gracefully shutting down the Server!"
            card_text = f"Gracefully shutting down the Server {os.environ['INSTANCE_ID']} at {os.environ['SERVER_FQDN']}"
        else:
            speak_output = "Error attempting to stop the Server!"
            card_text = f"Error shutting down the Server {os.environ['INSTANCE_ID']} at {os.environ['SERVER_FQDN']}"

        return (
            handler_input.response_builder
                .speak(speak_output)
                .set_card(
                        ui.StandardCard(
                            title=speak_output,
                            text=card_text,
                            # image=ui.Image(
                            #     small_image_url="<Small Image URL>",
                            #     large_image_url="<Large Image URL>"
                            # )
                        )
                    )
                # .ask("add a reprompt if you want to keep the session open for the user to respond")
                .response
        )
sb.add_request_handler(StopServerIntentHandler())


# Default Handler to also capture the lambda event
skill_handler = sb.lambda_handler()
def lambda_handler(event, context):
    logger.debug("Received Alexa event: " + json.dumps(event, sort_keys=True))
    try:
        results = skill_handler(event, context)
    except Exception as e:
        logger.critical("{}\nMessage: {}\nContext: {}".format(e, message, vars(context)))
        raise
    logger.debug(f"Returning {json.dumps(results, sort_keys=True)} to Alexa")
    return(results)

######## Don't touch below #######

#
# Alexa Required Handlers
#

class LaunchRequestHandler(AbstractRequestHandler):
    """Handler for Skill Launch."""
    def can_handle(self, handler_input):
        # type: (HandlerInput) -> bool

        return ask_utils.is_request_type("LaunchRequest")(handler_input)

    def handle(self, handler_input):
        # type: (HandlerInput) -> Response
        speak_output = "Welcome, you can start or stop the server. What would you like to do?"

        return (
            handler_input.response_builder
                .speak(speak_output)
                .ask(speak_output)
                .response
        )


class HelpIntentHandler(AbstractRequestHandler):
    """Handler for Help Intent."""
    def can_handle(self, handler_input):
        # type: (HandlerInput) -> bool
        return ask_utils.is_intent_name("AMAZON.HelpIntent")(handler_input)

    def handle(self, handler_input):
        # type: (HandlerInput) -> Response
        speak_output = "You can say hello to me! How can I help?"

        return (
            handler_input.response_builder
                .speak(speak_output)
                .ask(speak_output)
                .response
        )


class CancelOrStopIntentHandler(AbstractRequestHandler):
    """Single handler for Cancel and Stop Intent."""
    def can_handle(self, handler_input):
        # type: (HandlerInput) -> bool
        return (ask_utils.is_intent_name("AMAZON.CancelIntent")(handler_input) or
                ask_utils.is_intent_name("AMAZON.StopIntent")(handler_input))

    def handle(self, handler_input):
        # type: (HandlerInput) -> Response
        speak_output = "Goodbye!"

        return (
            handler_input.response_builder
                .speak(speak_output)
                .response
        )


class SessionEndedRequestHandler(AbstractRequestHandler):
    """Handler for Session End."""
    def can_handle(self, handler_input):
        # type: (HandlerInput) -> bool
        return ask_utils.is_request_type("SessionEndedRequest")(handler_input)

    def handle(self, handler_input):
        # type: (HandlerInput) -> Response

        # Any cleanup logic goes here.

        return handler_input.response_builder.response


class IntentReflectorHandler(AbstractRequestHandler):
    """The intent reflector is used for interaction model testing and debugging.
    It will simply repeat the intent the user said. You can create custom handlers
    for your intents by defining them above, then also adding them to the request
    handler chain below.
    """
    def can_handle(self, handler_input):
        # type: (HandlerInput) -> bool
        return ask_utils.is_request_type("IntentRequest")(handler_input)

    def handle(self, handler_input):
        # type: (HandlerInput) -> Response
        intent_name = ask_utils.get_intent_name(handler_input)
        speak_output = "You just triggered " + intent_name + "."

        return (
            handler_input.response_builder
                .speak(speak_output)
                # .ask("add a reprompt if you want to keep the session open for the user to respond")
                .response
        )


class CatchAllExceptionHandler(AbstractExceptionHandler):
    """Generic error handling to capture any syntax or routing errors. If you receive an error
    stating the request handler chain is not found, you have not implemented a handler for
    the intent being invoked or included it in the skill builder below.
    """
    def can_handle(self, handler_input, exception):
        # type: (HandlerInput, Exception) -> bool
        return True

    def handle(self, handler_input, exception):
        # type: (HandlerInput, Exception) -> Response
        logger.error(exception, exc_info=True)

        speak_output = "Sorry, I had trouble doing what you asked. Please try again."

        return (
            handler_input.response_builder
                .speak(speak_output)
                .ask(speak_output)
                .response
        )


# Alexa required Handlers
sb.add_request_handler(LaunchRequestHandler())
sb.add_request_handler(HelpIntentHandler())
sb.add_request_handler(CancelOrStopIntentHandler())
sb.add_request_handler(SessionEndedRequestHandler())
sb.add_request_handler(IntentReflectorHandler()) # make sure IntentReflectorHandler is last so it doesn't override your custom intent handlers
sb.add_exception_handler(CatchAllExceptionHandler())

