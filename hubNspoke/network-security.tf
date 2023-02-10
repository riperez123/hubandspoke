##############################################
# Network security groups - Primary region
##############################################

resource "azurerm_network_security_group" "any-to-any-onprem-primary" {
  name                = "any-to-any-onprem-primary"
  location            = azurerm_resource_group.primary-rg.location
  resource_group_name = azurerm_resource_group.primary-rg.name
}

resource "azurerm_network_security_rule" "allow-rfc-1918-primary-in" {
  name                         = "allow-rfc-1918-inbound"
  priority                     = 100
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "*"
  source_port_range            = "*"
  destination_port_range       = "*"
  source_address_prefixes      = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  destination_address_prefixes = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  resource_group_name          = azurerm_resource_group.primary-rg.name
  network_security_group_name  = azurerm_network_security_group.any-to-any-onprem-primary.name
}

resource "azurerm_network_security_rule" "allow-rfc-1918-primary-out" {
  name                         = "allow-rfc-1918-outbound"
  priority                     = 100
  direction                    = "Outbound"
  access                       = "Allow"
  protocol                     = "*"
  source_port_range            = "*"
  destination_port_range       = "*"
  source_address_prefixes      = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  destination_address_prefixes = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  resource_group_name          = azurerm_resource_group.primary-rg.name
  network_security_group_name  = azurerm_network_security_group.any-to-any-onprem-primary.name
}


resource "azurerm_firewall_policy" "onprem-primary-azfw-policy" {
  name                = "onprem-primary-azfw-policy"
  resource_group_name = azurerm_resource_group.primary-rg.name
  location            = azurerm_resource_group.primary-rg.location

  sku = "Premium"
}

resource "azurerm_firewall_policy_rule_collection_group" "onprem-primary-azfw-rulecollectiongroup" {
  name               = "onprem-primary-azfwpolicy-rcg"
  firewall_policy_id = azurerm_firewall_policy.onprem-primary-azfw-policy.id
  priority           = 300

  network_rule_collection {
    name     = "onprem-primary-allow-network-rules"
    priority = 100
    action   = "Allow"
    rule {
      name                  = "allow-access-to-any-from-onprem-site-1-vm"
      protocols             = ["Any"]
      source_addresses      = [azurerm_network_interface.onprem-site-1-vm-nic.ip_configuration[0].private_ip_address]
      destination_addresses = ["*"]
      destination_ports     = ["*"]
    }
  }
}
############################################
# Azure Firewall Policies - Primary region
############################################

resource "azurerm_firewall_policy" "primary-azfw-policy" {
  name                = "${var.primary-location}-azfw-policy"
  resource_group_name = azurerm_resource_group.primary-rg.name
  location            = azurerm_resource_group.primary-rg.location

  sku = "Premium"

  base_policy_id = azurerm_firewall_policy.onprem-primary-azfw-policy.id
}

resource "azurerm_firewall_policy_rule_collection_group" "primary-azfw-rulecollectiongroup" {
  name               = "${var.primary-location}-azfwpolicy-rcg"
  firewall_policy_id = azurerm_firewall_policy.primary-azfw-policy.id
  priority           = 500

  network_rule_collection {
    name     = "network_rule_collection1"
    priority = 500
    action   = "Allow"
    rule {
      name                  = "allow-spoke1-fe-to-spoke2-fe-in-${var.primary-location}"
      protocols             = ["Any"]
      source_ip_groups      = [azurerm_ip_group.primary-spoke1-fesubnet.id]
      destination_ip_groups = [azurerm_ip_group.primary-spoke2-fesubnet.id]
      destination_ports     = ["*"]
    }
    rule {
      name                  = "allow-spoke2-fe-to-spoke2-be-in-${var.primary-location}"
      protocols             = ["Any"]
      source_ip_groups      = [azurerm_ip_group.primary-spoke2-fesubnet.id]
      destination_ip_groups = [azurerm_ip_group.primary-spoke2-besubnet.id]
      destination_ports     = ["*"]
    }
  }
  network_rule_collection {
    name     = "onprem-allow-network-rules"
    priority = 100
    action   = "Allow"
    rule {
      name                  = "allow-access-to-any-from-onprem-site-1-vm"
      protocols             = ["Any"]
      source_addresses      = [azurerm_network_interface.onprem-site-1-vm-nic.ip_configuration[0].private_ip_address]
      destination_addresses = ["*"]
      destination_ports     = ["*"]
    }
  }
}





##############################
# Azure Firewall - Primary
##############################

resource "azurerm_public_ip" "azfw-pip-primary" {
  name                = "${var.primary-location}-azfw-pip"
  location            = azurerm_resource_group.primary-rg.location
  resource_group_name = azurerm_resource_group.primary-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "azfw-primary" {
  name                = "${var.primary-location}-azfw"
  location            = azurerm_resource_group.primary-rg.location
  resource_group_name = azurerm_resource_group.primary-rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Premium"

  firewall_policy_id = azurerm_firewall_policy.primary-azfw-policy.id

  ip_configuration {
    name                 = "ipconfig"
    subnet_id            = azurerm_subnet.primary-hub-azurefirewallsubnet.id
    public_ip_address_id = azurerm_public_ip.azfw-pip-primary.id
  }
}




##############################
# IP Groups
##############################

resource "azurerm_ip_group" "primary-hub" {
  name                = "${var.primary-location}-hub-vnet"
  location            = azurerm_resource_group.primary-rg.location
  resource_group_name = azurerm_resource_group.primary-rg.name

  cidrs = local.primary-hub-prefix
}

resource "azurerm_ip_group" "primary-hub-vmsubnet" {
  name                = "${var.primary-location}-hub-vmsubnet"
  location            = azurerm_resource_group.primary-rg.location
  resource_group_name = azurerm_resource_group.primary-rg.name

  cidrs = local.primary-hub-vmsubnet
}

resource "azurerm_ip_group" "primary-spoke1" {
  name                = "${var.primary-location}-spoke1"
  location            = azurerm_resource_group.primary-rg.location
  resource_group_name = azurerm_resource_group.primary-rg.name

  cidrs = local.primary-spoke1-prefix
}

resource "azurerm_ip_group" "primary-spoke1-fesubnet" {
  name                = "${var.primary-location}-spoke1-fesubnet"
  location            = azurerm_resource_group.primary-rg.location
  resource_group_name = azurerm_resource_group.primary-rg.name

  cidrs = local.primary-spoke1-fesubnet
}

resource "azurerm_ip_group" "primary-spoke1-besubnet" {
  name                = "${var.primary-location}-spoke1-besubnet"
  location            = azurerm_resource_group.primary-rg.location
  resource_group_name = azurerm_resource_group.primary-rg.name

  cidrs = local.primary-spoke1-besubnet
}

resource "azurerm_ip_group" "primary-spoke2" {
  name                = "${var.primary-location}-spoke2"
  location            = azurerm_resource_group.primary-rg.location
  resource_group_name = azurerm_resource_group.primary-rg.name

  cidrs = local.primary-spoke2-prefix
}

resource "azurerm_ip_group" "primary-spoke2-fesubnet" {
  name                = "${var.primary-location}-spoke2-fesubnet"
  location            = azurerm_resource_group.primary-rg.location
  resource_group_name = azurerm_resource_group.primary-rg.name

  cidrs = local.primary-spoke2-fesubnet
}

resource "azurerm_ip_group" "primary-spoke2-besubnet" {
  name                = "${var.primary-location}-spoke2-besubnet"
  location            = azurerm_resource_group.primary-rg.location
  resource_group_name = azurerm_resource_group.primary-rg.name

  cidrs = local.primary-spoke2-besubnet
}


resource "azurerm_ip_group" "onprem-site-1" {
  name                = "onprem-site-1"
  location            = azurerm_resource_group.primary-rg.location
  resource_group_name = azurerm_resource_group.primary-rg.name

  cidrs = local.onprem-site-1-prefix
}

resource "azurerm_ip_group" "onprem-site-1-vmsubnet" {
  name                = "onprem-site-1-vmsubnet"
  location            = azurerm_resource_group.primary-rg.location
  resource_group_name = azurerm_resource_group.primary-rg.name

  cidrs = local.onprem-site-1-vmsubnet
}

