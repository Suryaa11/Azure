resource "azurerm_application_gateway" "appgw" {

  name                = var.name
  resource_group_name = var.rg_name
  location            = var.location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gw-ip"
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  backend_address_pool {
    name = "vm1-pool"
  }

  backend_address_pool {
    name = "vm2-pool"
  }

  backend_http_settings {
    name                  = "http-settings"
    port                  = 80
    protocol              = "Http"
    cookie_based_affinity = "Disabled"
  }

  http_listener {
    name                           = "listener-vm1"
    frontend_ip_configuration_name = "frontend-ip"
    frontend_port_name            = "http-port"
    protocol                      = "Http"
    host_name                    = "organic.hmsclinic.online"
  }

  http_listener {
    name                           = "listener-vm2"
    frontend_ip_configuration_name = "frontend-ip"
    frontend_port_name            = "http-port"
    protocol                      = "Http"
    host_name                    = "fitness.hmsclinic.online"
  }

  request_routing_rule {
    name                       = "rule-vm1"
    rule_type                  = "Basic"
    http_listener_name         = "listener-vm1"
    backend_address_pool_name  = "vm1-pool"
    backend_http_settings_name  = "http-settings"
  }

  request_routing_rule {
    name                       = "rule-vm2"
    rule_type                  = "Basic"
    http_listener_name         = "listener-vm2"
    backend_address_pool_name  = "vm2-pool"
    backend_http_settings_name  = "http-settings"
  }
}