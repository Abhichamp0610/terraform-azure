subscription_id = "08071545-bc50-4650-b808-22834bebd85b"
tenant_id       = "16b3c013-d300-468d-ac64-7eda0820b6d3"
location        = "west europe"
name            = "terratestaml011"
resource_group = {
  id   = "/subscriptions/510497ba-4733-4571-9325-2150271a2a82/resourceGroups/test-rg"
  name = "test-rg"
}

#resource_group_name = "test-rg"

vnet = "terratestvnet01"
#dns_zone = "privatelink.api.azureml.ms"

subnets = {
  pe_subnet = {
    name_suffix   = "pe-subnet"
    address_space = "10.0.0.0/28"
  }
  compute_subnet = {
    name_suffix   = "compute-subnet"
    address_space = "10.0.0.16/28"
  }
  endpoint_subnet = {
    name_suffix   = "endpoint-subnet"
    address_space = "10.0.0.32/28"
  }
}

ml_private_endpoint_names = {
  name1 = "pe-api-aml"
  name2 = "pe-backend-aml"
}

private_dns_zone = {
  pvtedpt1 = "privatelink.api.azureml.ms"
  pvtedpt2 = "privatelink.notebooks.azure.net"
}
