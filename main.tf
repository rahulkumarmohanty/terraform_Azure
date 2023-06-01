resource "azurerm_resource_group" "resource_group" {
  name     = "${var.organization}-rg"
  location = "East US"
}

module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.resource_group.name
  address_spaces      = [var.cidr_block]
  subnet_prefixes     = [for i in range(var.subnet_count) : cidrsubnet(var.cidr_block,8,i)]
  subnet_names        = [for i in range(var.subnet_count): "${var.organization}-Subnet${i}"]
  use_for_each        = false
  vnet_name           = "${var.organization}-vnet"
  tags = {
    name = "${var.organization}-vnet"
  }
  depends_on = [azurerm_resource_group.resource_group]
}

module "linuxservers" {
  source              = "Azure/compute/azurerm"
  resource_group_name = azurerm_resource_group.resource_group.name
  vm_os_simple        = "UbuntuServer"
  vnet_subnet_id      = module.network.vnet_subnets[0]
  admin_username      = "1CHAdministrator"
  admin_password      = "Password123@"
  availability_set_enabled = false
  data_sa_type        = "Standard_LRS"
  data_disk_size_gb   = 30
  enable_ssh_key      = false
  location            = module.network.vnet_location
  storage_account_type = "Standard_LRS"
  vm_hostname         = "${var.organization}-public-vm"
  vm_size             = "Standard_B1s"
  zone                = "1"
  public_ip_sku       = "Standard"
  name_template_network_interface = azurerm_network_interface.nic.name
  depends_on = [azurerm_resource_group.resource_group]
}

module "network-security-group" {
  source                = "Azure/network-security-group/azurerm"
  resource_group_name   = azurerm_resource_group.resource_group.name
  location              = "EastUS" # Optional; if not provided, will use Resource Group location
  security_group_name   = "nsg"

  custom_rules = [
    {
      name                   = "myssh"
      priority               = 201
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "Tcp"
      source_port_range      = "*"
      destination_port_range = "50011"
      source_address_prefix  = "*"
      description            = "description-myssh"
    },
    {
      name                    = "http"
      priority                = 200
      direction               = "Inbound"
      access                  = "Allow"
      protocol                = "Tcp"
      source_port_range       = "*"
      destination_port_range  = "80"
      source_address_prefixe  = "*"
      description             = "description-http"
    },
    {
      name                    = "https"
      priority                = 202
      direction               = "Inbound"
      access                  = "Allow"
      protocol                = "Tcp"
      source_port_range       = "*"
      destination_port_range  = "443"
      source_address_prefixe  = "*"
      description             = "description-http"
    },
  ]

  depends_on = [azurerm_resource_group.resource_group]
}

resource "azurerm_network_interface" "nic" {
  name                = "public-vm-nic"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.network.vnet_subnets[0]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }

  depends_on = [ azurerm_public_ip.public_ip ]
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = module.network-security-group.network_security_group_id
}

resource "azurerm_public_ip" "public_ip" {
  name                = "acceptanceTestPublicIp1"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  allocation_method   = "Static"
  sku                 = "Standard"
}