provider "azurerm" {
	features {}
  	client_id = "719e783d-f72a-4e33-a84b-99b58cf0014e"
    client_secret = "b649rNnTp.trhr.oVcU_e2T.~-yy625jtg"
    tenant_id = "c9536685-1262-420b-a94b-4f5420284680"
    subscription_id = "6370c329-0366-4da1-9a03-0529f068a483"
}

variable "prefix" {
  default = "PackerTestEA"
}

variable "resourcegroup" {
	default = "saas-build-sig-01"
}
variable "location" {
	default = "East Asia"
}

variable "subscription_id" {
	default = "6370c329-0366-4da1-9a03-0529f068a483"
}
variable "tenant_id" {
	default = "c9536685-1262-420b-a94b-4f5420284680"
}

variable "imagename" {
	default = "imageunique"
}

/*
resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = "West Europe"
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
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "password123"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}
