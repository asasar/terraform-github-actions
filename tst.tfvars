location = "francecentral"
region   = "frc"

locationOpenAI = "swedencentral"
regionOpenAI   = "swc"

namingConvention = {
  environmentCode = "n"
  projectCode     = "wxc"
}

tags = {
  Environment                  = "Development",
  Project                      = "Syhunt",
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
    name         = "azrfrcsntdsaisha0010"
    addressSpace = ["172.28.201.192/28"]
  }
  #container app env
  subnet01 = {
    name         = "azrfrcsntdsaisha0011"
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

postgresqlAdminLogin    = "PostgreSqlLogin"
postgresqlAdminPassword = "PostgreSqlPassword"