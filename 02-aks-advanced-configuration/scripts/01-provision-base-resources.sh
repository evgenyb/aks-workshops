WS_PREFIX='iac-ws2'
YOUR_NAME='<USE YOU NAME>'                  # I am using "evg"
BASE_RG="$WS_PREFIX-base-rg"                # iac-ws2-base-rg
VNET_NAME=$WS_PREFIX-vnet                   # iac-ws2-vnet
LA_NAME="$WS_PREFIX-$YOUR_NAME-la"          # iac-ws2-evg-la
APPINSIGHTS_NAME="$WS_PREFIX-appinsights"   # iac-ws2-appinsights
PREFIX_NAME="$WS_PREFIX-pip-prefix"         # iac-ws2--pip-prefix
ACR_NAME="iacws2${YOUR_NAME}acr"            # iacws2evgacr

# Create base resource group
echo -e "Create resource group $BASE_RG"
az group create -g $BASE_RG -l westeurope

# Create APIM VNet with AGW subnet
echo -e "Create VNet $VNET_NAME in $BASE_RG"
az network vnet create -g $BASE_RG -n $VNET_NAME --address-prefix 10.10.0.0/16 --subnet-name apim-net --subnet-prefix 10.10.0.0/27

# Create Public IP Prefix
echo -e "Create Public IP Prefix $PREFIX_NAME in $BASE_RG"
az network public-ip prefix create --length 28 --location westeurope -n $PREFIX_NAME -g $BASE_RG

# Create AppInsight app
echo -e "Create Application Insights $APPINSIGHTS_NAME in $BASE_RG"
az monitor app-insights component create --app $APPINSIGHTS_NAME -l westeurope --kind web -g $BASE_RG --application-type web --retention-time 120

# Create Log Analytics
echo -e "Create Log Analytics $LA_NAME in $BASE_RG"
az monitor log-analytics workspace create -g $BASE_RG -n $LA_NAME

# Create Azure Container Registry
echo -e "Create Azure Container Registry $ACR_NAME in $BASE_RG"
az acr create -g $BASE_RG -n $ACR_NAME --sku Basic