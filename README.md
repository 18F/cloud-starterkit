# Agency cloud starter kit

Demonstrate power of cloud websites + Paas or FaaS

## Prerequisites

- Unix command line (e.g. bash)

## Azure

Install the azure-client, e.g. `brew install azure-cli`

Then, from, https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blob-static-website:

Set up to work:
```
az extension add --name storage-preview
az login
az account list
subscription_id=$(az account list | jq -r '.[0].id')
az account set --subscription $subscription_id
```

Manage storage accounts and resource groups

- Do I have resource group? `az group list`, if not create one (TKTK)
- Do I have a storage account?: `az storage account list`
- If not create one: 
```
  resource_group=$(az group list | jq -r '.[0].name')
  location=$(az group list | jq -r '.[0].location')
  storage_account_name=starterkitstorage
  az storage account create \
    --name starterkitstorage \
    --resource-group $resource_group \
    --location $location \
    --sku Standard_LRS \
    --kind StorageV2
```

Enable the feature:

```
az storage blob service-properties update \
  --account-name $storage_account_name \
  --static-website \
  --404-document 404.html \
  --index-document index.html
```

Query for endpoint URL:

```
azure_website=$(az storage account show -n $storage_account_name -g $resource_group \
   --query "primaryEndpoints.web" --output tsv)
```

Upload `web/` to the '$web' container:

```
az storage blob upload-batch -s ./web -d '$web' \
  --account-name $account_name
```

Preview it:

```
curl $azure_website
```

### Azure resources

[Getting Started with Azure CLI](https://docs.microsoft.com/en-us/cli/azure/get-started-with-azure-cli?view=azure-cli-latest)