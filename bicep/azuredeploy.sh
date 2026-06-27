#!/bin/bash

LOCATION="${1:-northeurope}"
RG_NAME="${2:-rg-docker-aspnet-apps-neu}"

SCRIPT_DIR=$(dirname "$0")

if ! command -v az &> /dev/null; then
    echo "Install Azure CLI: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

az account show --output none
if [ $? -ne 0 ]; then
    echo "Log into your Azure account: az login"
    exit 1
fi

echo "Create resource group $RG_NAME"
az group create -l $LOCATION -n $RG_NAME

echo "Deploy"
az deployment group create --name docker-aspnet-apps --resource-group $RG_NAME --template-file $SCRIPT_DIR/main.bicep

echo "Get outputs"
DEPLOYMENT_OUTPUT=$(az deployment group show --name docker-aspnet-apps --resource-group $RG_NAME --query "properties.outputs" --output json)
echo "rgName: $RG_NAME"
echo "keyVaultName: $(echo $DEPLOYMENT_OUTPUT | jq -r '.keyVaultName.value')"
echo "acrName: $(echo $DEPLOYMENT_OUTPUT | jq -r '.acrName.value')"
echo "acrLoginServer: $(echo $DEPLOYMENT_OUTPUT | jq -r '.acrLoginServer.value')"