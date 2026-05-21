resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.vm.name
  resource_group_name = var.rg_name
  location            = var.location
  size                = var.vm.size
  admin_username      = var.vm.admin_username
  admin_password      = var.vm.admin_password
  network_interface_ids = [var.nic_id]

  custom_data = var.custom_data

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}