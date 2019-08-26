# Define Terraform Provider To Use

provider "azurerm" {
}

# Create Resource Group in Azure

resource "azurerm_resource_group" "tuffy01" {
    name     = "tuffy0001"
    location = "westus"
}
