# encoding: utf-8
# copyright: 2018, The Authors

title 'sample section'
resource_group = 'starterkitRG'

control 'azure core resources existence' do
  impact 1.0
  title 'The azure resources must exist'
  describe azurerm_resource_groups.where(name: resource_group) do
    it { should exist }
  end

  describe azurerm_storage_account_blob_container(
    resource_group: resource_group, 
    storage_account_name: 'starterkitstorage',
    blob_container_name: '$web'
  ) do
    it { should exist }
    its('name') { should eq('$web') }
  end

end


# Some equivalent commands from az cli:
# az storage container list --account-name $storage_account_name
# az storage container show -n '$web' --account-name $storage_account_name
# az storage blob service-properties show --account-name $storage_account_name
#   look for 'staticWebsite'
#   look also for logging