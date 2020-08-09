# minecraft
AWS Hosted Minecraft server with Alexa control



### Alexa Deploy Secret

1. Vendor ID from this URL: https://developer.amazon.com/mycid.html
2. ClientID & Secret from here: https://developer.amazon.com/loginwithamazon/console/site/lwa/overview.html
3. refresh token:
	1. Install the [ASK CLI tool](https://developer.amazon.com/en-US/docs/alexa/smapi/quick-start-alexa-skills-kit-command-line-interface.html)
	2. Run `ask util generate-lwa-tokens --scope alexa::ask:skills:readwrite`

Json should look like:

```json
{
  "client_id": "amzn1.application-oa2-client.REDACTED",
  "client_secret": "REDACTED",
  "refresh_token": "Atzr|BIG-LOG-SESSION-TOKEN-BLAH",
  "vendor_id": "M1C39XXXXXXXG"
}
```