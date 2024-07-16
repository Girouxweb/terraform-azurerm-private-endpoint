terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0, < 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0, < 4.0.0"
    }
  }
}
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  skip_provider_registration = true
  storage_use_azuread        = true
}
module "private_endpoint" {
  source = "../../"

  private_endpoints = {
    example = {
      location            = "East US"
      resource_group_name = "example-resources"
      name                = "example"
      subnet_resource_id  = azurerm_subnet.example.id
      private_dns_zone_resource_ids = [
        azurerm_private_dns_zone.example.id,
      ]
    }
  }
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = "East US"
  resource_group_name = "module.private_endpoint.example-resources"
}

resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_virtual_network.example.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_private_dns_zone" "example" {
  name                = "privatelink.example.com"
  resource_group_name = azurerm_virtual_network.example.resource_group_name
}