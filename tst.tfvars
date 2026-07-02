location = "francecentral"
region   = "frc"

locationOpenAI = "swedencentral"
regionOpenAI   = "swc"

namingConvention = {
  environmentCode = "n"
  projectCode     = "wxc"
}

tags = {
  Environment                  = "Test",
  Project                      = "Syhunt",
  Application                  = "Syhunt",
  Region                       = "Europe",
  AsCode                       = "Terraform",
  SecurityConfidentialityLevel = "Private",
  SecurityComplianceLevel      = "EAR"
  Owner                        = "stephane.maraut@syensqo.com",
  CostCenter                   = "NSO.PX24101.ISAO",
  Approver                     = "vincent.colegrave@syensqo.com"
}

# Networking

vnetShared000 = {
  addressSpace = ["172.28.201.192/26"]
  # PEP
  subnet00 = {
    name         = "azrfrcsnttsyhsha0000"
    addressSpace = ["172.28.201.192/28"]
  }
  #container app env
  subnet01 = {
    name         = "azrfrcsnttsyhsha0001"
    addressSpace = ["172.28.201.224/27"]
  }
}

azureFirewallPrivateIP = "172.28.8.132"

# Shared GenAI Services
logAnalyticsWorkspaceID = "/subscriptions/6f81aaae-fb33-41ba-8399-0b51ddaf3bee/resourceGroups/aks-devtest-rg/providers/Microsoft.OperationalInsights/workspaces/defaultworkspace-6f81aaae-fb33-41ba-8399-0b51ddaf3bee-par"



modelsShared = {
  "gpt-4o" = {
    deploymentName = "gpt-4o"
    modelName      = "gpt-4o"
    format         = "OpenAI"
    version        = "2024-11-20"
    type           = "Standard"
    capacity       = "10"
  }
}

applicationSpecificNsgRules = {
  pep = [
    {
      name                     = "allow-cae-to-pep-postgres-5432"
      priority                 = 200
      direction                = "Inbound"
      access                   = "Allow"
      protocol                 = "Tcp"
      sourcePortRange          = "*"
      destinationPortRange     = "5432"
      sourceAddressPrefix      = "172.28.201.224/27"
      destinationAddressPrefix = "172.28.201.192/28"
      description              = "Allow PostgreSQL traffic from CAE subnet to private endpoint subnet"
    }
  ]
  cae = [
    {
      name                     = "allow-internet-to-web-8080"
      priority                 = 200
      direction                = "Inbound"
      access                   = "Allow"
      protocol                 = "Tcp"
      sourcePortRange          = "*"
      destinationPortRange     = "8080"
      sourceAddressPrefix      = "Internet"
      destinationAddressPrefix = "172.28.201.224/27"
      description              = "Allow external web ingress on port 8080"
    },
    {
      name                     = "allow-azure-lb-to-app-5050"
      priority                 = 210
      direction                = "Inbound"
      access                   = "Allow"
      protocol                 = "Tcp"
      sourcePortRange          = "*"
      destinationPortRange     = "5050"
      sourceAddressPrefix      = "AzureLoadBalancer"
      destinationAddressPrefix = "172.28.201.224/27"
      description              = "Allow platform load balancer traffic to internal app port 5050"
    },
    {
      name                     = "allow-cae-to-pep-postgres-5432"
      priority                 = 220
      direction                = "Outbound"
      access                   = "Allow"
      protocol                 = "Tcp"
      sourcePortRange          = "*"
      destinationPortRange     = "5432"
      sourceAddressPrefix      = "172.28.201.224/27"
      destinationAddressPrefix = "172.28.201.192/28"
      description              = "Allow outbound PostgreSQL traffic from CAE subnet"
    },
    {
      name                     = "allow-cae-to-azure-monitor-443"
      priority                 = 230
      direction                = "Outbound"
      access                   = "Allow"
      protocol                 = "Tcp"
      sourcePortRange          = "*"
      destinationPortRange     = "443"
      sourceAddressPrefix      = "172.28.201.224/27"
      destinationAddressPrefix = "AzureMonitor"
      description              = "Allow telemetry export to Application Insights via Azure Monitor"
    },
    {
      name                     = "allow-cae-to-foundry-443"
      priority                 = 240
      direction                = "Outbound"
      access                   = "Allow"
      protocol                 = "Tcp"
      sourcePortRange          = "*"
      destinationPortRange     = "443"
      sourceAddressPrefix      = "172.28.201.224/27"
      destinationAddressPrefix = "AzureCloud"
      description              = "Allow HTTPS access from CAE subnet to Azure Foundry model endpoints"
    }
  ]
}

PostgreSqlConfig = {
  sku                  = "B_Standard_B4ms"
  storageTiers         = "P6"
  storageSize          = 35536
  highAvailabilityMode = "Disabled"
}