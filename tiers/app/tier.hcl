# =============================================================================
# AZURE TIER CONFIGURATION - APP TIER
# =============================================================================
# This file defines tier-specific configurations for the APPLICATION layer.
# Part of the 5-layer configuration hierarchy:
#
#   root.hcl → region.hcl → env.hcl → tier.hcl → terragrunt.hcl
#
# The APP tier handles:
#   - Application servers (VMs, VMSS, AKS)
#   - Internal load balancers
#   - App Services / Functions
#   - API Management
#   - Service Bus / Event Hubs
# =============================================================================

locals {
  # ==========================================================================
  # TIER IDENTIFICATION
  # ==========================================================================
  tier_name        = "app"
  tier_code        = "app"
  tier_description = "Application processing tier with internal services"
  tier_order       = 2  # Deployment order (after web, before data)
  
  # ==========================================================================
  # AZURE NETWORKING - APP TIER
  # ==========================================================================
  subnet_config = {
    address_prefix_size = 23  # /23 = 510 hosts (more for app tier)
    
    service_endpoints = [
      "Microsoft.Storage",
      "Microsoft.Sql",
      "Microsoft.KeyVault",
      "Microsoft.ServiceBus",
      "Microsoft.EventHub",
      "Microsoft.AzureCosmosDB",
    ]
    
    delegation = null
    
    private_endpoint_network_policies_enabled     = true
    private_link_service_network_policies_enabled = true
  }
  
  # ==========================================================================
  # AZURE NSG RULES - APP TIER
  # ==========================================================================
  nsg_rules = {
    inbound = [
      {
        name                       = "Allow-WebTier-Inbound"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "*"
        description                = "Allow traffic from Web tier"
      },
      {
        name                       = "Allow-InternalLB"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "AzureLoadBalancer"
        destination_address_prefix = "*"
        description                = "Allow Internal Load Balancer"
      },
      {
        name                       = "Allow-AppToApp"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080-8089"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "*"
        description                = "Allow inter-app communication"
      },
      {
        name                       = "Allow-Bastion"
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges    = ["22", "3389"]
        source_address_prefix      = "AzureBastionSubnet"
        destination_address_prefix = "*"
        description                = "Allow Azure Bastion access"
      },
      {
        name                       = "Deny-All-Inbound"
        priority                   = 4096
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
        description                = "Deny all other inbound traffic"
      },
    ]
    
    outbound = [
      {
        name                       = "Allow-DataTier-Outbound"
        priority                   = 100
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges    = ["1433", "5432", "3306", "6379", "27017"]
        source_address_prefix      = "*"
        destination_address_prefix = "VirtualNetwork"
        description                = "Allow outbound to Data tier databases"
      },
      {
        name                       = "Allow-Storage"
        priority                   = 110
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "Storage"
        description                = "Allow Azure Storage access"
      },
      {
        name                       = "Allow-KeyVault"
        priority                   = 120
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "AzureKeyVault"
        description                = "Allow Azure Key Vault access"
      },
      {
        name                       = "Allow-ServiceBus"
        priority                   = 130
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges    = ["443", "5671", "5672"]
        source_address_prefix      = "*"
        destination_address_prefix = "ServiceBus"
        description                = "Allow Azure Service Bus"
      },
      {
        name                       = "Allow-EventHub"
        priority                   = 140
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges    = ["443", "5671", "5672"]
        source_address_prefix      = "*"
        destination_address_prefix = "EventHub"
        description                = "Allow Azure Event Hub"
      },
      {
        name                       = "Allow-AzureMonitor"
        priority                   = 200
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "AzureMonitor"
        description                = "Allow Azure Monitor telemetry"
      },
      {
        name                       = "Deny-Internet-Outbound"
        priority                   = 4096
        direction                  = "Outbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "Internet"
        description                = "Deny direct internet outbound"
      },
    ]
  }
  
  # ==========================================================================
  # AZURE INTERNAL LOAD BALANCER
  # ==========================================================================
  internal_lb_config = {
    sku                            = "Standard"
    frontend_ip_configuration_name = "InternalFrontend"
    
    backend_pool = {
      name = "AppBackendPool"
    }
    
    health_probe = {
      name                = "AppHealthProbe"
      protocol            = "Http"
      port                = 8080
      request_path        = "/health"
      interval_in_seconds = 15
      number_of_probes    = 2
    }
    
    lb_rules = [
      {
        name                  = "AppRule"
        protocol              = "Tcp"
        frontend_port         = 8080
        backend_port          = 8080
        idle_timeout_minutes  = 4
        enable_floating_ip    = false
        enable_tcp_reset      = true
      },
    ]
  }
  
  # ==========================================================================
  # AZURE COMPUTE - APP TIER VMs
  # ==========================================================================
  vm_config = {
    default_vm_size = "Standard_D4s_v3"  # Larger for app processing
    
    os_disk = {
      caching              = "ReadWrite"
      storage_account_type = "Premium_LRS"
      disk_size_gb         = 128
    }
    
    data_disks = [
      {
        lun                  = 0
        caching              = "ReadOnly"
        storage_account_type = "Premium_LRS"
        disk_size_gb         = 256
        create_option        = "Empty"
      },
    ]
    
    availability_zone_enabled = true
    boot_diagnostics_enabled  = true
    
    extensions = [
      "AzureMonitorLinuxAgent",
      "DependencyAgentLinux",
      "CustomScript",
    ]
  }
  
  # ==========================================================================
  # AZURE APP SERVICE (Alternative to VMs)
  # ==========================================================================
  app_service_config = {
    sku_name = "P2v3"
    
    site_config = {
      always_on                = true
      http2_enabled            = true
      minimum_tls_version      = "1.2"
      ftps_state               = "Disabled"
      vnet_route_all_enabled   = true
      remote_debugging_enabled = false
      
      ip_restriction_default_action     = "Deny"
      scm_ip_restriction_default_action = "Deny"
    }
    
    identity = {
      type = "SystemAssigned"
    }
  }
  
  # ==========================================================================
  # AZURE SERVICE BUS
  # ==========================================================================
  service_bus_config = {
    sku                 = "Premium"
    capacity            = 1
    premium_messaging_partitions = 1
    
    queues = [
      {
        name                         = "app-commands"
        max_size_in_megabytes        = 5120
        enable_partitioning          = false
        requires_duplicate_detection = true
        dead_lettering_on_message_expiration = true
      },
    ]
    
    topics = [
      {
        name                = "app-events"
        max_size_in_megabytes = 5120
        enable_partitioning  = false
        
        subscriptions = [
          {
            name                         = "processor"
            max_delivery_count           = 10
            dead_lettering_on_filter_evaluation_error = true
          },
        ]
      },
    ]
  }
  
  # ==========================================================================
  # AZURE MONITORING - APP TIER
  # ==========================================================================
  monitoring_config = {
    metrics = [
      "Percentage CPU",
      "Available Memory Bytes",
      "Disk Queue Depth",
      "Network In Total",
      "Network Out Total",
    ]
    
    alerts = {
      high_cpu = {
        metric_name = "Percentage CPU"
        operator    = "GreaterThan"
        threshold   = 75
        aggregation = "Average"
        window_size = "PT5M"
        frequency   = "PT1M"
        severity    = 2
      }
      low_memory = {
        metric_name = "Available Memory Bytes"
        operator    = "LessThan"
        threshold   = 1073741824  # 1GB
        aggregation = "Average"
        window_size = "PT5M"
        frequency   = "PT1M"
        severity    = 2
      }
      high_disk_queue = {
        metric_name = "Disk Queue Depth"
        operator    = "GreaterThan"
        threshold   = 32
        aggregation = "Average"
        window_size = "PT5M"
        frequency   = "PT1M"
        severity    = 3
      }
    }
    
    log_categories = [
      "AppServiceHTTPLogs",
      "AppServiceConsoleLogs",
      "AppServiceAppLogs",
      "AppServiceAuditLogs",
      "AppServicePlatformLogs",
    ]
  }
  
  # ==========================================================================
  # TIER-SPECIFIC TAGS
  # ==========================================================================
  tier_tags = {
    tier          = local.tier_name
    tier_code     = local.tier_code
    tier_order    = tostring(local.tier_order)
    public_facing = "false"
    internal_only = "true"
    message_driven = "true"
  }
}
