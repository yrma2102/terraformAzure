resource "azurerm_resource_group" "rg-demo" {
    name = var.rg_name
    location = var.rg_location

    tags = {
      "Grupo" = var.rg_group
    }
}

resource "azurerm_virtual_network" "vnet-demo" {
    name = var.vnet_name
    address_space = var.vnet_address_space
    location = azurerm_resource_group.rg-demo.location
    resource_group_name = azurerm_resource_group.rg-demo.name
}

resource "azurerm_subnet" "subnet-demo" {
    name = var.subnet_name
    resource_group_name = azurerm_resource_group.rg-demo.name
    virtual_network_name = azurerm_virtual_network.vnet-demo.name
    address_prefixes = var.subnet_address_prefixes
}

resource "azurerm_container_registry" "acr-demo" {
    name = var.acr_name
    resource_group_name = azurerm_resource_group.rg-demo.name
    location = azurerm_resource_group.rg-demo.location
    sku = var.acr_sku
    admin_enabled = var.acr_admin_enabled
}
#crear cluster con version 1.24.3
#Habilitar Rbac
#autoescalado entre 1 a 3
resource "azurerm_kubernetes_cluster" "aks-demo" {
    name = var.aks_name
    location = azurerm_resource_group.rg-demo.location
    resource_group_name = azurerm_resource_group.rg-demo.name
    dns_prefix = var.aks_dns_prefix
    kubernetes_version = var.aks_kubernetes_version
    role_based_access_control_enabled = var.aks_rbac_enabled

    default_node_pool {
      name = var.aks_np_name
      node_count = var.aks_np_node_count
      vm_size = var.aks_np_vm_size
      vnet_subnet_id = azurerm_subnet.subnet-demo.id
      enable_auto_scaling = var.aks_np_enabled_auto_scaling
      max_count = var.aks_np_max_count
      min_count = var.aks_np_min_count
      max_pods = "80"
    }

    service_principal {
      client_id = var.aks_sp_client_id
      client_secret = var.aks_sp_client_secret
    }
#policiy
#network
  network_profile {
    network_plugin = var.aks_net_plugin
    network_policy = var.aks_net_policy
  }
}
#agregar pool de nodos adicional con label:adicional
resource "azurerm_kubernetes_cluster_node_pool" "aks-demo" {
  name                  = "internal"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks-demo.id
  vm_size               = var.aks_np_vm_size
  node_count            = 1
  max_pods = "80"

  tags = {
    Environment = "Production"

  }
}
#especificar la cantidad de pod por nodo en 80
