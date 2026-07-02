##############################
# Resource Group: Networking
##############################
module "ResourceGroupShared0000" {
  source = "./Modules/terraform/azurerm/ResourceGroup"

  namingConvention = { environmentCode = var.namingConvention.environmentCode
    projectCode = "sai"
  }
  tierCode  = "sha"
  location  = var.location
  region    = var.region
  increment = "0000"

  tags = var.tags
  specificTags = {
    Tier        = var.tierTag,
    Description = "Netwo${var.tierTag}",
  }
}

##############################
# Virtual Network
##############################
module "VirtualNetworkShared0000" {
  source = "./Modules/terraform/azurerm/VirtualNetwork"

  namingConvention  = var.namingConvention
  tierCode          = "sha"
  location          = var.location
  region            = var.region
  increment         = "0000"
  monitorIncrement  = "0000"
  resourceGroupName = module.ResourceGroupShared0000.ResourceGroupName

  tags = var.tags
  specificTags = {
    Tier        = var.tierTag,
    Description = "Virtual Network for ${var.tierTag}",
  }

  dnsServers = [var.azureFirewallPrivateIP]
  vnetCIDR   = var.vnetShared000.addressSpace

  subnetsConfig = {
    "${var.vnetShared000.subnet00.name}" = {
      addressPrefixes = var.vnetShared000.subnet00.addressSpace
      delegations     = []
    }
    "${var.vnetShared000.subnet01.name}" = {
      addressPrefixes = var.vnetShared000.subnet01.addressSpace
      delegations = [
        {
          name        = "Microsoft.App.environments"
          serviceName = "Microsoft.App/environments"
          actions     = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      ]
    }
  }
}

##############################
# NSGs per subnet
##############################
locals {
  subnetNsgConfig = {
    pep = {
      nsgName    = "azrfrcnsg${var.namingConvention.environmentCode}syhsha0000"
      subnetName = var.vnetShared000.subnet00.name
    }
    cae = {
      nsgName    = "azrfrcnsg${var.namingConvention.environmentCode}syhsha0001"
      subnetName = var.vnetShared000.subnet01.name
    }
  }

  appSpecificRulesBySubnet = {
    for subnetKey in keys(local.subnetNsgConfig) : subnetKey => concat(
      lookup(var.applicationSpecificNsgRules, subnetKey, []),
      lookup(var.applicationSpecificNsgRules, "${subnetKey}_dev", [])
    )
  }

  appSpecificRulesFlattened = flatten([
    for subnetKey, rules in local.appSpecificRulesBySubnet : [
      for rule in rules : merge(rule, {
        subnetKey = subnetKey
        ruleKey   = "${subnetKey}-${rule.name}"
      })
    ]
  ])
}

resource "azurerm_network_security_group" "subnet" {
  for_each = local.subnetNsgConfig

  name                = each.value.nsgName
  location            = var.location
  resource_group_name = module.ResourceGroupShared0000.ResourceGroupName

  tags = merge(var.tags, {
    Tier        = var.tierTag
    Description = "NSG for subnet ${each.value.subnetName}"
  })

  lifecycle {
    precondition {
      condition     = length(local.appSpecificRulesBySubnet[each.key]) > 0
      error_message = "Application-specific NSG rules are required for ${each.key}. Update variable applicationSpecificNsgRules before deployment."
    }
  }
}

resource "azurerm_network_security_rule" "baseline_inbound_deny_internet" {
  for_each = local.subnetNsgConfig

  name                        = "deny-inbound-internet"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = module.ResourceGroupShared0000.ResourceGroupName
  network_security_group_name = azurerm_network_security_group.subnet[each.key].name
}

resource "azurerm_network_security_rule" "baseline_outbound_allow" {
  for_each = local.subnetNsgConfig

  name                        = "allow-outbound-all"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = module.ResourceGroupShared0000.ResourceGroupName
  network_security_group_name = azurerm_network_security_group.subnet[each.key].name
}

resource "azurerm_network_security_rule" "application_specific" {
  for_each = {
    for rule in local.appSpecificRulesFlattened : rule.ruleKey => rule
    if contains(keys(local.subnetNsgConfig), rule.subnetKey)
  }

  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.sourcePortRange
  destination_port_range      = each.value.destinationPortRange
  source_address_prefix       = each.value.sourceAddressPrefix
  destination_address_prefix  = each.value.destinationAddressPrefix
  resource_group_name         = module.ResourceGroupShared0000.ResourceGroupName
  network_security_group_name = azurerm_network_security_group.subnet[each.value.subnetKey].name
  description                 = each.value.description
}

resource "azurerm_subnet_network_security_group_association" "subnet" {
  for_each = local.subnetNsgConfig

  subnet_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${module.ResourceGroupShared0000.ResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${module.VirtualNetworkShared0000.VirtualNetworkName}/subnets/${each.value.subnetName}"

  network_security_group_id = azurerm_network_security_group.subnet[each.key].id
}
