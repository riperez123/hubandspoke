##############################
# Onprem site 1
##############################

resource "azurerm_virtual_network" "onprem-site-1-vnet" {
  name                = "onprem-site-1-vnet"
  location            = var.primary-location
  resource_group_name = azurerm_resource_group.primary-rg.name
  address_space       = local.onprem-site-1-prefix
}

resource "azurerm_subnet" "onprem-site-1-gatewaysubnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.primary-rg.name
  virtual_network_name = azurerm_virtual_network.onprem-site-1-vnet.name
  address_prefixes     = local.onprem-site-1-gatewaysubnet
}

resource "azurerm_subnet" "onprem-site-1-azurebastionsubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.primary-rg.name
  virtual_network_name = azurerm_virtual_network.onprem-site-1-vnet.name
  address_prefixes     = local.onprem-site-1-azurebastionsubnet
}

resource "azurerm_subnet" "onprem-site-1-vmsubnet" {
  name                 = "vmsubnet"
  resource_group_name  = azurerm_resource_group.primary-rg.name
  virtual_network_name = azurerm_virtual_network.onprem-site-1-vnet.name
  address_prefixes     = local.onprem-site-1-vmsubnet
}

resource "azurerm_subnet_network_security_group_association" "onprem-site-1-nsg-a" {
  subnet_id                 = azurerm_subnet.onprem-site-1-vmsubnet.id
  network_security_group_id = azurerm_network_security_group.any-to-any-onprem-primary.id
}


#########################################################
# VPN Gateway
#########################################################  
resource "azurerm_public_ip" "onprem-site-1-vpngw-pip-1" {
  name                = "onprem-site-1-vpngw-pip-1"
  location            = azurerm_resource_group.primary-rg.location
  resource_group_name = azurerm_resource_group.primary-rg.name

  allocation_method = "Dynamic"
}

resource "azurerm_public_ip" "onprem-site-1-vpngw-pip-2" {
  name                = "onprem-site-1-vpngw-pip-2"
  location            = azurerm_resource_group.primary-rg.location
  resource_group_name = azurerm_resource_group.primary-rg.name

  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "onprem-site-1-vpngw" {
  name                = "onprem-site-1-vpngw"
  location            = azurerm_resource_group.primary-rg.location
  resource_group_name = azurerm_resource_group.primary-rg.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = true
  enable_bgp    = true
  sku           = "VpnGw2"
  generation    = "Generation2"

  ip_configuration {
    name                          = "ipconfig1"
    public_ip_address_id          = azurerm_public_ip.onprem-site-1-vpngw-pip-1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.onprem-site-1-gatewaysubnet.id
  }

  ip_configuration {
    name                          = "ipconfig2"
    public_ip_address_id          = azurerm_public_ip.onprem-site-1-vpngw-pip-2.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.onprem-site-1-gatewaysubnet.id
  }

  bgp_settings {
    asn = "65555"
  }
}

resource "azurerm_virtual_network_gateway_connection" "onprem-site-1-to-primary" {
  name                = "onprem-site-1-to-${var.primary-location}"
  location            = azurerm_resource_group.primary-rg.location
  resource_group_name = azurerm_resource_group.primary-rg.name

  type                            = "Vnet2Vnet"
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.onprem-site-1-vpngw.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.primary-vpngw.id
  enable_bgp                      = true
  shared_key                      = var.vpngw-shared-key
}

resource "azurerm_virtual_network_gateway_connection" "primary-to-onprem-site-1" {
  name                = "${var.primary-location}-to-onprem-site-1"
  location            = azurerm_resource_group.primary-rg.location
  resource_group_name = azurerm_resource_group.primary-rg.name

  type                            = "Vnet2Vnet"
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.primary-vpngw.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.onprem-site-1-vpngw.id
  enable_bgp                      = true
  shared_key                      = var.vpngw-shared-key
}






#########################################################
# Azure Bastion
######################################################### 

resource "azurerm_public_ip" "onprem-site-1-bastion-pip" {
  name                = "onprem-site-1-bastion-pip"
  location            = azurerm_resource_group.primary-rg.location
  resource_group_name = azurerm_resource_group.primary-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "onprem-site-1-bastion" {
  name                = "onprem-site-1-bastion"
  location            = azurerm_resource_group.primary-rg.location
  resource_group_name = azurerm_resource_group.primary-rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.onprem-site-1-azurebastionsubnet.id
    public_ip_address_id = azurerm_public_ip.onprem-site-1-bastion-pip.id
  }
}