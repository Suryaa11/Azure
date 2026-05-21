resource "azurerm_network_interface" "nic" {
  name                = var.nic.name
  resource_group_name = var.rg_name
  location            = var.location

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}