data "azurerm_resource_group" "CloudX" {
  name = "CloudX-CI"
}

resource "azurerm_virtual_network" "CloudX" {
  name                = "CloudX-network"
  address_space       = ["10.0.0.0/21"]
  location            = data.azurerm_resource_group.CloudX.location
  resource_group_name = data.azurerm_resource_group.CloudX.name
}

resource "azurerm_subnet" "CloudX" {
  name                 = "CloudX-Ghatkopar"
  resource_group_name  = data.azurerm_resource_group.CloudX.name
  virtual_network_name = azurerm_virtual_network.CloudX.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "CloudX2" {
  name                 = "CloudX-Kurla"
  resource_group_name  = data.azurerm_resource_group.CloudX.name
  virtual_network_name = azurerm_virtual_network.CloudX.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_public_ip" "CloudX" {
  name                = "CloudX-public-ip"
  resource_group_name = data.azurerm_resource_group.CloudX.name
  location            = data.azurerm_resource_group.CloudX.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "CloudX" {
  name                = "CloudX-nsg"
  location            = data.azurerm_resource_group.CloudX.location
  resource_group_name = data.azurerm_resource_group.CloudX.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.my_public_ip
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "CloudX" {
  name                = "CloudX-nic"
  location            = data.azurerm_resource_group.CloudX.location
  resource_group_name = data.azurerm_resource_group.CloudX.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.CloudX.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.10"
    public_ip_address_id          = azurerm_public_ip.CloudX.id
  }
}

resource "azurerm_network_interface_security_group_association" "CloudX" {
  network_interface_id      = azurerm_network_interface.CloudX.id
  network_security_group_id = azurerm_network_security_group.CloudX.id
}

resource "azurerm_linux_virtual_machine" "rocky" {
  name                = "cloudx-rocky-vm"
  computer_name       = "cloudx-rocky-vm"
  resource_group_name = data.azurerm_resource_group.CloudX.name
  location            = data.azurerm_resource_group.CloudX.location
  size                = "Standard_D2as_v4"

  network_interface_ids = [
    azurerm_network_interface.CloudX.id
  ]

  admin_username                  = "vishnu"
  admin_password                  = var.admin_password
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "resf"
    offer     = "rockylinux-x86_64"
    sku       = "9-base"
    version   = "latest"
  }

  plan {
    publisher = "resf"
    product   = "rockylinux-x86_64"
    name      = "9-base"
  }
}

resource "azurerm_network_security_group" "servers" {
  name                = "CloudX-servers-nsg"
  location            = data.azurerm_resource_group.CloudX.location
  resource_group_name = data.azurerm_resource_group.CloudX.name

  security_rule {
    name                       = "Allow-SSH-from-jumpbox"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.2.10/32"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "spot_servers" {
  for_each = toset(["spot-1", "spot-2", "spot-3", "spot-4"])

  name                = "CloudX-${each.key}-nic"
  location            = data.azurerm_resource_group.CloudX.location
  resource_group_name = data.azurerm_resource_group.CloudX.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.CloudX2.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "spot_servers" {
  for_each = azurerm_network_interface.spot_servers

  network_interface_id      = each.value.id
  network_security_group_id = azurerm_network_security_group.servers.id
}

resource "azurerm_linux_virtual_machine" "spot_servers" {
  for_each = azurerm_network_interface.spot_servers

  name                = "CloudX-${each.key}"
  computer_name       = "cloudx-${each.key}"
  resource_group_name = data.azurerm_resource_group.CloudX.name
  location            = data.azurerm_resource_group.CloudX.location
  size                = "Standard_D2as_v4"

  network_interface_ids = [each.value.id]

  admin_username                  = "vishnu"
  admin_password                  = var.admin_password
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "resf"
    offer     = "rockylinux-x86_64"
    sku       = "9-base"
    version   = "latest"
  }

  plan {
    publisher = "resf"
    product   = "rockylinux-x86_64"
    name      = "9-base"
  }
}

output "spot_server_private_ips" {
  value = {
    for name, nic in azurerm_network_interface.spot_servers :
    name => nic.private_ip_address
  }
}

output "jumpbox_public_ip" {
  value = azurerm_public_ip.CloudX.ip_address
}


