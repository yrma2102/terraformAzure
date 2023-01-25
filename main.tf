#crear maquina virtual en la cual se pueda instalar jenkins mediante ansible
#resource group
resource "azurerm_resource_group" "rg-demo" {
    name = var.name
    location = var.location
    tags = {
      "Sec" = 2
      "Grupo" = 7
    }
}

resource "azurerm_public_ip" "pip-demo" {
    name = "public-ip"
    resource_group_name = azurerm_resource_group.rg-demo.name
    location = azurerm_resource_group.rg-demo.location
    allocation_method = "Static"
    tags = {
      "diplomado" = "sec2"
      "Grupo" = 7
    }
}

#virtual network
resource "azurerm_virtual_network" "vnet-demo" {
    name = "diploGrupo7-net"
    address_space = [ "10.0.0.0/16" ]
    location = azurerm_resource_group.rg-demo.location
    resource_group_name = azurerm_resource_group.rg-demo.name
}

#subnet
resource "azurerm_subnet" "subnet-demo" {
    name = "internal"
    resource_group_name = azurerm_resource_group.rg-demo.name
    virtual_network_name = azurerm_virtual_network.vnet-demo.name
    address_prefixes = [ "10.0.2.0/24" ]
}

resource "azurerm_network_interface" "netinter-demo" {
    name = "networkinterface"
    location = azurerm_resource_group.rg-demo.location
    resource_group_name = azurerm_resource_group.rg-demo.name
    ip_configuration {
      name = "internal"
      subnet_id = azurerm_subnet.subnet-demo.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id = azurerm_public_ip.pip-demo.id
    }
}

resource "azurerm_linux_virtual_machine" "vm-demo" {
    name = "diplo-machine-grupo7"
    resource_group_name = azurerm_resource_group.rg-demo.name
    location = azurerm_resource_group.rg-demo.location
    size = "Standard_B1s"
    network_interface_ids = [ azurerm_network_interface.netinter-demo.id ]
    os_disk {
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }

    source_image_reference {
      publisher = "Canonical"
      offer = "UbuntuServer"
      sku = "16.04-LTS"
      version = "latest"
    }

    computer_name = "hostname"
    admin_username = "DiplomadoGrupo7"
    admin_password = "DiplomadoGrupo7$"
    disable_password_authentication = false
  
}