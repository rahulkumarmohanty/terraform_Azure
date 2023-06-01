terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.58.0"
    }
  }
}

provider "azurerm" {
    features {}
    client_id       = "80400782-02ec-4f98-b1e2-f0c4dd8067a8"
    client_secret   = "nDJ8Q~w4PLzVtmcYNFWQ9nnFSL1fRcsksGSOBb6t"
    tenant_id       = "d6a66152-b819-4636-b222-ca6fd2fad656"
    subscription_id = "2153dcaa-22b1-42d6-8ce6-f576f5ecd16d"

}