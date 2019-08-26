# Define Terraform Provider To Use

provider "azurerm" {
}

# Create Resource Group in Azure

resource "azurerm_resource_group" "tuffy01" {
    name     = "tuffy01"
    location = "westus"

    tags {
        environment = "Terraform Demo"
    }
}

# Create a virtual network in Azure
resource "azurerm_virtual_network" "tuffyvnet" {
    name = "tuffydemovnet"
    address_space = ["10.0.0.0/16"]
    location = "West US"
    resource_group_name = "${azurerm_resource_group.tuffy01.name}"
}

# Create subnet in Azure
resource "azurerm_subnet" "tuffysubnet" {
    name = "Demo"
    resource_group_name = "${azurerm_resource_group.tuffy01.name}"
    virtual_network_name = "${azurerm_virtual_network.tuffyvnet.name}"
    address_prefix = "10.0.2.0/24"
}

# Create public IP in Azure
resource "azurerm_public_ip" "tuffypubip" {
    name = "tuffytestip"
    location = "West US"
    resource_group_name = "${azurerm_resource_group.tuffy01.name}"
    public_ip_address_allocation = "dynamic"

    tags {
        environment = "TerraformDemo"
    }
}

# Create network interface in Azure
resource "azurerm_network_interface" "tuffynic" {
    name = "tuffytfni"
    location = "West US"
    resource_group_name = "${azurerm_resource_group.tuffy01.name}"

    ip_configuration {
        name = "testconfiguration1"
        subnet_id = "${azurerm_subnet.tuffysubnet.id}"
        private_ip_address_allocation = "static"
        private_ip_address = "10.0.2.5"
        public_ip_address_id = "${azurerm_public_ip.tuffypubip.id}"
    }
}

# Create storage account in Azure
resource "azurerm_storage_account" "tuffystorageacct01" {
  name                     = "tuffystorageacct01"
  resource_group_name      = "${azurerm_resource_group.tuffy01.name}"
  location                 = "westus"
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}

# Create storage container in Azure
resource "azurerm_storage_container" "tuffystoragecontainer" {
    name = "vhd"
    resource_group_name = "${azurerm_resource_group.tuffy01.name}"
    storage_account_name = "${azurerm_storage_account.tuffystorageacct01.name}"
    container_access_type = "private"
    depends_on = ["azurerm_storage_account.tuffystorageacct01"]
}

# Create virtual machine in Azure
resource "azurerm_virtual_machine" "tuffytfvm01" {
    name = "terraformvm"
    location = "West US"
    resource_group_name = "${azurerm_resource_group.tuffy01.name}"
    network_interface_ids = ["${azurerm_network_interface.tuffynic.id}"]
    vm_size = "Standard_A0"

    storage_image_reference {
        publisher = "Canonical"
        offer = "UbuntuServer"
        sku = "14.04.2-LTS"
        version = "latest"
    }

    storage_os_disk {
        name = "myosdisk"
        vhd_uri = "${azurerm_storage_account.tuffystorageacct01.primary_blob_endpoint}${azurerm_storage_container.tuffystoragecontainer.name}/myosdisk.vhd"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = "tuffy03"
        admin_username = "ahead"
        admin_password = "Password1234!"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    tags {
        environment = "Terraform Demo"
    }
}
