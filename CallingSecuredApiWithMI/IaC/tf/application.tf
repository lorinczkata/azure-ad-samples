resource "azurerm_app_service_plan" "plan" {
  name                = "app_service_plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "linux"
  reserved            = true
  sku {
    tier = "Basic"
    size = "B1"
  }
}
resource "azurerm_app_service" "web_portal" {
  name                = local.web_portal_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.plan.id
  https_only          = true

  identity {
    type = "SystemAssigned"
  }
  app_settings = {
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = false
    "APP_REGISTRATION_TENANTID"      = "${data.azuread_client_config.current.tenant_id}"
    "APP_REGISTRATION_CLINENTID"     = "${azuread_application.web_portal_ad_app.application_id}"
    "AUTHENTICATION_TURNED_ON"       = true
  }
  auth_settings {
    enabled             = true
    token_store_enabled = true
    default_provider    = "AzureActiveDirectory"
    active_directory {
      client_id = azuread_application.web_portal_ad_app.application_id
    }
    issuer                        = "https://sts.windows.net/${data.azuread_client_config.current.tenant_id}/"
    unauthenticated_client_action = "RedirectToLoginPage"
  }



  site_config {
    app_command_line = "dotnet WebApi.dll"
    dotnet_framework_version = "v6.0"
    ftps_state       = "Disabled"
    always_on        = true
    min_tls_version  = "1.2"
    cors {
      allowed_origins     = []
      support_credentials = true
    }
  }

}

resource "azuread_application" "web_portal_ad_app" {
  display_name     = local.web_portal_name
  sign_in_audience = "AzureADMyOrg"
  identifier_uris = ["https://${local.web_portal_name}.azurewebsites.net"]
  owners           = [data.azuread_client_config.current.object_id]

  api {
    requested_access_token_version = 2
  }

  single_page_application {
    redirect_uris = ["https://${local.web_portal_name}.azurewebsites.net/", "https://${local.web_portal_name}.azurewebsites.net/.auth/login/aad/callback", "http://localhost:3000/"]

  }

  web {
    implicit_grant {
      access_token_issuance_enabled = true
      id_token_issuance_enabled     = true
    }
  }

  required_resource_access {
    # user.read
    resource_app_id = "00000003-0000-0000-c000-000000000000"
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }
  }
}

resource "random_uuid" "uuid" {}