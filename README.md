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
  resource_group=starterkitRG
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
  --account-name $storage_account_name
```

Preview it:

```
curl $azure_website
```

## Validating

Getting a static site up is the least interesting part. How do we validate that the site is set up the way we want?

Thanks to http://www.anniehedgie.com/inspec-basics-11 for guidance here:

Get the subscription_id (assuming you have only one):

```
subscription_id=$(az account list | jq -r '.[0].id')
```

Install inspec:

Set up Service Principal: **The output of this is required for your credentials**
```
az ad sp create-for-rbac -n "MyApp" --role contributor
```

```
$ az ad sp create-for-rbac -n "MyAppPrincipal" --role contributor
Changing "MyAppPrincipal" to a valid URI of "http://MyAppPrincipal", which is the required format used for service principal names
Retrying role assignment creation: 1/36
{
  "appId": "48b9bba3-YOUR-GUID-HERE-90f0b68ce8ba,
  "displayName": "MyAppPrincipal",
  "name": "http://MyAppPrincipal",
  "password": "your-client-secret-here",
  "tenant": "9c117323-YOUR-GUID-HERE-9ee430723ba3"
}
```

Create ~/.azure/credentials where:

```
[$subscription_id]
client_id = "<appId> from above `az ad sp ...`"
client_secret = "<password> from above `az ad sp ...`"
tenant_id = "<tenant> from above `az ad sp ...`
```

Create the inspec profile:

```
inspec init profile inspec-starterkit --overwrite
```

Add inspec-azure to `inspec-starterkit/inspec.yml`

```
depends:
  - name: inspec-azure
    url: https://github.com/inspec/inspec-azure/archive/master.tar.gz
supports:
  platform: azure
```

Now run inspec:

```
inspec exec inspec-starterkit -t azure://$subscription_id
```

Sample output:

```
$ inspec exec inspec-starterkit -t azure://$subscription_id

Profile: InSpec Profile (inspec-starterkit)
Version: 0.1.0
Target:  azure://310338ec-e189-4169-a39c-2f58efcab2c7

  ✔  azure resource group existence: The azure resource group must exist
     ✔  Resource Groups with name == "starterkitRG" should exist
```

## Assuring compliance

At this point we've shown we can create a website with code and use Inspec to validate simple existence. Let's add some compliance, namely, making sure we're gathering access logs, which could be a facet of NIST 800-53 AU-2: "Audit events"


az storage blob service-properties set \
  --account-name $storage_account_name \
  --set logging.write=true
  --set property1.property2=<value>.


 az storage logging update \
   --log rwd --services bqt --retention 90 --account-name $storage_account_name

* Logging is now true

 Get-AzStorageServiceLoggingProperty -Context $ctx -ServiceType Blob
 

Now change directory to `tf-starterkit` for the Terraform work.

Install required dependencies:

```
terraform init

In the `tf-starter/` directory, create `terraform.tfvars` with the credentials for your Azure account. You can just re-purpose your azure `.credentials` file:

```
  cat ~/.azure/credentials | 
    sed -e 's/\[/subscription_id = \"/; s/\]/\"/' > tf-starterkit/terraform.tfvars
  chmod 400 tf-starterkit/terraform.tfvars
```

## Destroy and  move on to the next example

Destroy:

```
az resource delete -n starterkitstorage -g starterkitRG --resource-type "Microsoft.Storage/storageAccounts"
```





### Azure resources

[Getting Started with Azure CLI](https://docs.microsoft.com/en-us/cli/azure/get-started-with-azure-cli?view=azure-cli-latest)