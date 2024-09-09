
data "azurerm_virtual_network" "vnet1" {
  name = var.vnet
  #resource_group_name = var.resource_group_name
  resource_group_name = var.resource_group.name
}

data "azurerm_private_dns_zone" "privatedns1" {
  name = var.private_dns_zone.pvtedpt1
  resource_group_name = var.resource_group.name
}

data "azurerm_private_dns_zone" "privatedns2" {
  name = var.private_dns_zone.pvtedpt2
  resource_group_name = var.resource_group.name
}

module "avm-res-network-virtualnetwork-subnet1" {
  source     = "Azure/avm-res-network-virtualnetwork/azurerm//modules/subnet"
  depends_on = [module.avm-res-network-networksecuritygroup, module.avm-res-network-routetable]
  for_each   = var.subnets

  virtual_network = {
    resource_id = data.azurerm_virtual_network.vnet1.id
  }
  name           = "${var.name}-${each.value.name_suffix}"
  address_prefix = each.value.address_space
network_security_group = {
  id = module.avm-res-network-networksecuritygroup[each.key].resource.id
}
  route_table = {
    id = module.avm-res-network-routetable.resource.id
  } 
}

module "avm-res-network-networksecuritygroup" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.2.0"

  for_each = var.subnets
  location = var.location
  name = "${each.value.name_suffix}-NSG"
  #name                = "subnets-nsg"
  resource_group_name = var.resource_group.name
  
}

module "avm-res-network-routetable" {
  source  = "Azure/avm-res-network-routetable/azurerm"
  version = "0.2.2"
  # insert the 3 required variables here
  name                = "${var.name}-routetable"
  resource_group_name = var.resource_group.name
  location            = var.location
  routes = {
    route1 = {
      name                   = "test-route-VirtualAppliance"
      address_prefix         = "10.0.1.0/24"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.0.4"
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "example" {
  for_each = var.subnets

  subnet_id                 = module.avm-res-network-virtualnetwork-subnet1[each.key].resource.id
  network_security_group_id = module.avm-res-network-networksecuritygroup[each.key].resource.id
}

module "avm-res-machinelearningservices-workspace" {
  source  = "Azure/avm-res-machinelearningservices-workspace/azurerm"
  version = "0.1.2"

  location = var.location
  name     = var.name
  #resource_group_name = var.resource_group_name
  resource_group = var.resource_group
  kind           = "Default"
  is_private     = true

  # Private endpoint values for machine learning workspace
  private_endpoints = {
    "api" = {
      name               = var.ml_private_endpoint_names.name1
      #name               = "pe-api-aml"
      subnet_resource_id = module.avm-res-network-virtualnetwork-subnet1["pe_subnet"].resource.id
      private_dns_zone_resource_ids = [data.azurerm_private_dns_zone.privatedns1.id, data.azurerm_private_dns_zone.privatedns2.id ]
    }
    # "backend" = {
    #   name               = var.ml_private_endpoint_names.name2
    #   subnet_resource_id = "/subscriptions/510497ba-4733-4571-9325-2150271a2a82/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/terratestvnet/subnets/PE_Subnet"
    # }
  }

  # key vault creation and associating private endpint
  key_vault = {
    create_new = true
    private_endpoints = {
      "key_vault_1" = {
        subnet_resource_id = module.avm-res-network-virtualnetwork-subnet1["pe_subnet"].resource.id
        #private_dns_zone_resource_ids = [ "value" ]
      }
    }
  }

  # storage account creation and associating private endpint
  storage_account = {
    create_new = true
    private_endpoints = {
      "storage_1" = {
        subnet_resource_id = module.avm-res-network-virtualnetwork-subnet1["pe_subnet"].resource.id
        subresource_name   = "blob"
        #private_dns_zone_resource_ids = [ "value" ]
      }
    }
  }

  # container registry creation and associating private endpint
  container_registry = {
    create_new = true
    private_endpoints = {
      "container_registry_1" = {
        subnet_resource_id = module.avm-res-network-virtualnetwork-subnet1["pe_subnet"].resource.id
        #private_dns_zone_resource_ids = [ "value" ]
      }
    }
  }
}

# resource "azurerm_private_dns_a_record" "example" {
#   name                = "example-ml-workspace"
#   zone_name           = data.azurerm_private_dns_zone.privatedns.name
#   resource_group_name = var.resource_group.name
#   ttl                 = 30
#   records             = [module.avm-res-machinelearningservices-workspace.private_endpoints["pe-api-aml"].private_ip_address]
# }