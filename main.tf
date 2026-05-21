terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "rg" {
  source = "./modules/rg"

  rg = var.rg
}

module "vnet" {
  source = "./modules/vnet"
  vnet_name            = var.vnet.name
  address_space        = var.vnet.address_space
  resource_group_name  = module.rg.rg_name
  location             = module.rg.location
}

module "subnet1" {
  source = "./modules/subnet"

  subnet = var.subnet1
  vnet_name = module.vnet.vnet_name
  rg_name   = module.rg.rg_name
}

module "subnet2" {
  source = "./modules/subnet"

  subnet = var.subnet2
  vnet_name = module.vnet.vnet_name
  rg_name   = module.rg.rg_name
}

module "nsg" {
  source = "./modules/nsg"

  rg_name = module.rg.rg_name
  location = module.rg.location
  nsg = var.nsg
}

module "nic1" {
  source = "./modules/nic"

  nic = var.nic1
  subnet_id = module.subnet1.subnet_id
  rg_name = module.rg.rg_name
  location = module.rg.location
}

module "nic2" {
  source = "./modules/nic"

  nic = var.nic2
  subnet_id = module.subnet1.subnet_id
  rg_name = module.rg.rg_name
  location = module.rg.location
}

module "vm1" {
  source = "./modules/vm"

  vm = var.vm1
  nic_id = module.nic1.nic_id
  rg_name = module.rg.rg_name
  location = module.rg.location

  custom_data = base64decode(file("app1.sh"))
}

module "vm2" {
  source = "./modules/vm"

  vm = var.vm2
  nic_id = module.nic2.nic_id
  rg_name = module.rg.rg_name
  location = module.rg.location

  custom_data = base64decode(file("app1.sh"))
}

module "appgw" {
  source = "./modules/appgw"

  rg_name = module.rg.rg_name
  location = module.rg.location

  subnet_id = module.subnet2.subnet_id
  public_ip = var.appgw_public_ip

  vm1_ip = module.vm1.private_ip
  vm2_ip = module.vm2.private_ip
}