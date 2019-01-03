# encoding: utf-8
# copyright: 2018, The Authors

title 'sample section'
resource_group = 'myResourceGroup'

control 'azure resource group existence' do
  impact 1.0
  title 'The azure resource group must exist'
  describe azurerm_resource_groups.where(name: resource_group) do
    it { should exist }
  end
end
