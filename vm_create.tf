provider "azurerm" {
	features {}
  	client_id = "134bea01-5247-4bcf-bbc5-700f91a61ca6"
    client_secret = "JIFQFq7w-XSbv36pU6_lQWyDj2gM6MH1pa"
    tenant_id = "00c023c5-6848-4fbe-bc02-abf3bf584bbe"
    subscription_id = "85dc525a-7861-44e9-a686-be41401bdd42"
}

variable "prefix" {
  default = "PackerTestEA3"
}

variable "resourcegroup" {
	default = "myResourceGroup1"
}
variable "location" {
	default = "East Asia"
}

variable "subscription_id" {
	default = "85dc525a-7861-44e9-a686-be41401bdd42"
}
variable "tenant_id" {
	default = "00c023c5-6848-4fbe-bc02-abf3bf584bbe"
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
    name              = "myosdisk2"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = ${{ secrets.ADMIN_USERNAME }}
    admin_password = ${{ secrets.ADMIN_PASSWORD }}
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}
