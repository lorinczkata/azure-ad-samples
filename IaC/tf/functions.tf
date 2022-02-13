resource "azurerm_storage_account" "storage_account" {
  name                     = "mmstoragetstsa"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "functions_plan" {
  name                = "mm_functions_plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "functions_app" {
  name                       = local.function_app_name
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_app_service_plan.functions_plan.id
  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  version                    = "~4"

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "dotnet"
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
    "WEB_API_AD_APP_ID_URI": "https://${azurerm_app_service.web_portal.default_site_hostname}"
    "WEB_API_URL":  "https://${azurerm_app_service.web_portal.default_site_hostname}"
  }

  site_config {
    ftps_state               = "Disabled"
    min_tls_version          = "1.2"
    dotnet_framework_version = "v6.0"
    cors {
      support_credentials = true
      allowed_origins     = ["http://localhost:3000", "https://${azurerm_app_service.web_portal.default_site_hostname}"]
    }
  }

}

data "azuread_client_config" "current" {}
