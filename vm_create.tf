provider "azurerm" {
	features {}
  	client_id = "client_id"
    client_secret = "client_secret"
    tenant_id = "tenant_id"
    subscription_id = "SUBSCRIPTION"
}

variable "prefix" {
  default = "PackerTestEU10"
}

variable "resourcegroup" {
	default = "saas-build-sig-01"
}
variable "location" {
	default = "REGION"
}

variable "subscription_id" {
	default = "SUBSCRIPTION"
}
variable "tenant_id" {
	default = "tenant_id"
}
variable "client_secret" {
	default = "client_secret"
}
variable "client_id" {
	default = "client_id"
}
variable "imagename" {
	default = "imageunique"
}


/*
resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = "East US 2"
}*/

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.location}"
  resource_group_name = "${var.resourcegroup}"
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = "${var.resourcegroup}"
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = "${var.location}"
  resource_group_name = "${var.resourcegroup}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = "${var.location}"
  resource_group_name   = "${var.resourcegroup}"
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
	id				  = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resourcegroup}/providers/Microsoft.Compute/images/${var.imagename}"
  }
  storage_os_disk {
    name              = "myosdisk22"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "password!123"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}
