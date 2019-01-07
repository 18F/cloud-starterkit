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
      resource_group: 'rg', 
      storage_account_name: 'default', 
      blob_container_name: 'logs'
  ) do
    it { should exist }
    its('name') { should eq('logs') }
  end

  describe azurerm_storage_account_blob_container(
    resource_group: resource_group, 
    storage_account_name: 'starterkitstorage',
    blob_container_name: '$web'
  ) do
    it { should exist }
    its('name') { should eq('logs') }
  end

end
