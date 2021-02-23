# lab-09 - 

## Estimated completion time - xx min


## Goals

## Task #1 - 

```bash
# Import api-b API to APIM using OpenAPI swagger.json file
az apim api import \
	--resource-group iac-ws2-base-rg --service-name iac-ws2-evg-apim \
	--path '/api-b' \
	--api-id api-b --display-name api-b \
	--specification-format OpenApiJson --specification-path swagger.json \
	--subscription-required false	
```

## Useful links
https://docs.microsoft.com/en-us/cli/azure/apim/api?view=azure-cli-latest
https://docs.microsoft.com/en-us/cli/azure/apim/api?view=azure-cli-latest#az_apim_api_import
https://docs.microsoft.com/en-us/cli/azure/apim/nv?view=azure-cli-latest



## Next: 

[Go to lab-10](../lab-10/readme.md)

## Feedback

* Visit the [Github Issue](https://github.com/evgenyb/aks-workshops/issues/xx) to comment on this lab. 