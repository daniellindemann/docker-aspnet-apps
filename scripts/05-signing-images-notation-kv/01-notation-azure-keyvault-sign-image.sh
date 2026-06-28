#!/usr/bin/env bash

# Usage:
#   ./01-notation-azure-keyvault-sign-image.sh <keyvault> <acr> [image] [cert_name] [cert_subject] [cert_path]
#
# Parameters:
#   <keyvault>
#     Name of the existing Azure Key Vault used to store the signing certificate.
#   <acr>
#     Name of the Azure Container Registry (with or without .azurecr.io).
#   [image]
#     Optional local image reference to tag, push, and sign.
#     Default: docker-aspnet-apps/sample-api:10-alpine
#   [cert_name]
#     Optional certificate name in Azure Key Vault.
#     Default: dlindemann-dev
#   [cert_subject]
#     Optional x509 certificate subject.
#     Default: CN=dlindemann.dev,O=abtis GmbH,L=Berlin,ST=Berlin,C=Germany
#   [cert_path]
#     Optional output path for downloading the certificate.
#     Default: ../../temp/notation-kv/<cert_name>.pem
#
# Examples:
#   ./01-notation-azure-keyvault-sign-image.sh mykv myacr
#   ./01-notation-azure-keyvault-sign-image.sh mykv myacr docker-aspnet-apps/sample-api:10-alpine

set -euo pipefail

script_dir=$(dirname "$0")
temp_dir="$script_dir/../../temp/notation-kv"
mkdir -p "$temp_dir"

# parameters passed to the script
# Name of the existing AKV used to store the signing keys
akv_name="${1:-myakv}"
# Name of the existing registry example: myregistry.azurecr.io
acr_name="${2:-myregistry}"
# local image to use for signing
image="${3:-docker-aspnet-apps/sample-api:10-alpine}"
# Name of the certificate created in AKV
cert_name="${4:-dlindemann-dev}"
cert_subject="${5:-CN=dlindemann.dev,O=abtis GmbH,L=Berlin,ST=Berlin,C=Germany}"
cert_path="${6:-$temp_dir/$cert_name.pem}"

# script variables
# Existing full domain of the ACR
registry=$([[ $acr_name == *.azurecr.io ]] && echo $acr_name || echo "$acr_name.azurecr.io")
# Container name inside ACR where image will be stored
acr_image=$registry/$image
# repo
acr_repo=$(echo $acr_image | cut -d':' -f1)
# notion config variables
store_type='ca'
store_name='dlindemann.dev'

# functions
message_and_wait() {
    local message="$1"
    echo ""
    echo "$message"
    read -p "Press Enter to continue..."
}

# check prerequisites
if ! command -v az &> /dev/null; then
    echo "Install Azure CLI: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

az account show --output none
if [ $? -ne 0 ]; then
    echo "Log into your Azure account: az login"
    exit 1
fi

# --- Developer part ---
echo ""
echo "D E V E L O P E R   P A R T"
echo "---------------------------"

message_and_wait "> 📜 Create certificate ${cert_name} in key vault ${akv_name}"
# create cert policy
cat <<EOF > $temp_dir/cert_policy.json
{
  "issuerParameters": {
    "certificateTransparency": null,
    "name": "Self"
  },
  "keyProperties": {
    "exportable": false,
    "keySize": 2048,
    "keyType": "RSA",
    "reuseKey": true
  },
  "x509CertificateProperties": {
    "ekus": [
      "1.3.6.1.5.5.7.3.3"
    ],
    "keyUsage": [
      "digitalSignature"
    ],
    "subject": "$cert_subject",
    "validityInMonths": 12
  }
}
EOF

# use policy to create a self-signed certificate in the key vault
# check if the certificate already exists
if az keyvault certificate show -n $cert_name --vault-name $akv_name > /dev/null 2>&1; then
    echo "Certificate $cert_name already exists in key vault $akv_name. Skipping creation."
else
    echo "Creating certificate $cert_name in key vault $akv_name..."
    az keyvault certificate create -n $cert_name --vault-name $akv_name -p @$temp_dir/cert_policy.json
fi

message_and_wait "> 🏷️ Tag image with ACR prefix and push"
# retag the image with the ACR prefix
docker tag "$image" "$acr_image"
# login to ACR
az acr login --name $acr_name
# push the image to ACR
docker push "$acr_image"
sleep 3

message_and_wait "> 🖋️ Sign image with Notation and Azure Key Vault"
# get key vault signing key id
key_id=$(az keyvault certificate show -n $cert_name --vault-name $akv_name --query 'kid' -o tsv)
digest=$(az acr repository show -n $acr_name -t $image --query 'digest' -o tsv)
image_with_digest="$acr_image@$digest"
echo "Signing the image using the CBOR Object Signing and Encryption (COSE) signature"
notation sign --signature-format cose \
    --id $key_id \
    --plugin azure-kv \
    --plugin-config self_signed=true \
    "$image_with_digest"

message_and_wait "> 🔑 Show the signature for the image"
notation ls $acr_image

message_and_wait "Gimme more! Ops part please!!!"

# --- Operations part ---
echo ""
echo "O P E R A T I O N S   P A R T"
echo "-----------------------------"

message_and_wait "> 🔽📜 Download signing certificate from Azure Key Vault"
rm -f -- "$cert_path"
az keyvault certificate download --name $cert_name --vault-name $akv_name --file $cert_path
cat $cert_path

message_and_wait "> 🏪 Add certifcate to Notation store"
notation cert delete --type "$store_type" --store "$store_name" -a -y 2> /dev/null || true
notation cert add --type "$store_type" --store "$store_name" "$cert_path"

message_and_wait "> 🧑‍⚖️ Create trust policy for repository $acr_image"
echo "ℹ️ Info:"
echo "Trust policies enable users to specify fine-tuned verification policies."
echo "They allow you to define which signers are trusted for a given repository, and what signature formats are acceptable."
message_and_wait ''

cat <<EOF > $temp_dir/trust_policy.json
{
    "version": "1.0",
    "trustPolicies": [
        {
            "name": "dlindemann-dev-images",
            "registryScopes": [ "$acr_repo" ],
            "signatureVerification": {
                "level" : "strict" 
            },
            "trustStores": [ "$store_type:$store_name" ],
            "trustedIdentities": [
                "x509.subject: $cert_subject"
            ]
        }
    ]
}
EOF

notation policy import $temp_dir/trust_policy.json
notation policy show

message_and_wait "> 🕵️ Verify image $acr_image"
notation verify $acr_image
