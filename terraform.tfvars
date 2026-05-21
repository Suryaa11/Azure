rg = {
  name     = "peering-rg"
  location = "Central India"
}

vnet = {
  name          = "main-vnet"
  address_space = ["10.0.0.0/16"]
}

subnet1 = {
  name           = "subnet-1"
  address_prefix = ["10.0.1.0/24"]
}

subnet2 = {
  name           = "subnet-2"
  address_prefix = ["10.0.2.0/24"]
}

vm1 = {
  name = "vm1"
  size = "Standard_B2s"
  admin_username = "surya"
  admin_password = "Password@12345"
}

vm2 = {
  name = "vm2"
  size = "Standard_B2s"
  admin_username = "surya"
  admin_password = "Password@12345"
}

nic1 = {
  name = "nic1"
}

nic2 = {
  name = "nic2"
}

nsg = {
  name = "vm-nsg"
}

appgw = {
  name = "app-gateway"
}

appgw_public_ip = {
  name = "appgw-pip"
  allocation_method = "Static"
  sku = "Standard"
}