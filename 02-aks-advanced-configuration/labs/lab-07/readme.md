# lab-07 - deploy API to API Management

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
* [az apim api](https://docs.microsoft.com/en-us/cli/azure/apim/api?WT.mc_id=AZ-MVP-5003837&view=azure-cli-latest)
* [az apim api import
](https://docs.microsoft.com/en-us/cli/azure/apim/api?WT.mc_id=AZ-MVP-5003837&view=azure-cli-latest#az_apim_api_import)
* [az apim nv](https://docs.microsoft.com/en-us/cli/azure/apim/nv?WT.mc_id=AZ-MVP-5003837&view=azure-cli-latest)

## Next: 

[Go to lab-08](../lab-08/readme.md)

## Feedback

* Visit the [Github Issue](https://github.com/evgenyb/aks-workshops/issues/22) to comment on this lab. 