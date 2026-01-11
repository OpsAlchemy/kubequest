# =============================================================================
# AZURE TIER CONFIGURATION - WEB TIER
# =============================================================================
# This file defines tier-specific configurations for the WEB layer.
# Part of the 5-layer configuration hierarchy:
#
#   root.hcl → region.hcl → env.hcl → tier.hcl → terragrunt.hcl
#
# The WEB tier handles:
#   - Public-facing resources (Application Gateway, Front Door)
#   - Web Application Firewall (WAF)
#   - Public IPs and Load Balancers
#   - CDN endpoints
#   - SSL/TLS termination
# =============================================================================

locals {
  # ==========================================================================
  # TIER IDENTIFICATION
  # ==========================================================================
  tier_name        = "web"
  tier_code        = "web"
  tier_description = "Public-facing web tier with WAF and load balancing"
  tier_order       = 1  # Deployment order (web first, then app, then data)
  
  # ==========================================================================
  # AZURE NETWORKING - WEB TIER
  # ==========================================================================
  # Subnet configuration for web tier
  subnet_config = {
    address_prefix_size = 24  # /24 = 254 hosts
    
    # Service endpoints for web tier
    service_endpoints = [
      "Microsoft.Web",
      "Microsoft.KeyVault",
      "Microsoft.Storage",
    ]
    
    # Delegations
    delegation = null  # No delegation for web tier
    
    # Private endpoint policies
    private_endpoint_network_policies_enabled     = false
    private_link_service_network_policies_enabled = false
  }
  
  # ==========================================================================
  # AZURE NSG RULES - WEB TIER
  # ==========================================================================
  nsg_rules = {
    # Inbound rules
    inbound = [
      {
        name                       = "Allow-HTTPS-Inbound"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "Internet"
        destination_address_prefix = "*"
        description                = "Allow HTTPS from Internet"
      },
      {
        name                       = "Allow-HTTP-Inbound"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "Internet"
        destination_address_prefix = "*"
        description                = "Allow HTTP for redirect to HTTPS"
      },
      {
        name                       = "Allow-AzureLoadBalancer"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "AzureLoadBalancer"
        destination_address_prefix = "*"
        description                = "Allow Azure Load Balancer health probes"
      },
      {
        name                       = "Allow-GatewayManager"
        priority                   = 130
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "65200-65535"
        source_address_prefix      = "GatewayManager"
        destination_address_prefix = "*"
        description                = "Allow Application Gateway v2 management"
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
    
    # Outbound rules
    outbound = [
      {
        name                       = "Allow-AppTier-Outbound"
        priority                   = 100
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080"
        source_address_prefix      = "*"
        destination_address_prefix = "VirtualNetwork"
        description                = "Allow outbound to App tier"
      },
      {
        name                       = "Allow-AzureCloud"
        priority                   = 200
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "AzureCloud"
        description                = "Allow outbound to Azure services"
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
  # AZURE APPLICATION GATEWAY / WAF
  # ==========================================================================
  application_gateway_config = {
    sku_name     = "WAF_v2"
    sku_tier     = "WAF_v2"
    sku_capacity = 2
    
    autoscale_config = {
      min_capacity = 2
      max_capacity = 10
    }
    
    waf_config = {
      enabled                  = true
      firewall_mode            = "Prevention"
      rule_set_type            = "OWASP"
      rule_set_version         = "3.2"
      file_upload_limit_mb     = 100
      max_request_body_size_kb = 128
      request_body_check       = true
      
      # Disabled rule groups (customize as needed)
      disabled_rule_groups = []
      
      # Custom exclusions
      exclusions = []
    }
    
    ssl_policy = {
      policy_type          = "Predefined"
      policy_name          = "AppGwSslPolicy20220101S"
      min_protocol_version = "TLSv1_2"
    }
  }
  
  # ==========================================================================
  # AZURE FRONT DOOR (Optional CDN)
  # ==========================================================================
  front_door_config = {
    enabled       = true
    sku_name      = "Premium_AzureFrontDoor"
    
    waf_policy = {
      enabled = true
      mode    = "Prevention"
    }
    
    caching = {
      query_string_caching_behavior = "IgnoreQueryString"
      compression_enabled           = true
    }
  }
  
  # ==========================================================================
  # AZURE COMPUTE - WEB TIER VMs
  # ==========================================================================
  vm_config = {
    # VM sizes by environment (overridden by env.hcl)
    default_vm_size = "Standard_D2s_v3"
    
    os_disk = {
      caching              = "ReadWrite"
      storage_account_type = "Premium_LRS"
      disk_size_gb         = 128
    }
    
    data_disks = []  # Web tier typically doesn't need data disks
    
    # Availability configuration
    availability_zone_enabled = true
    
    # Boot diagnostics
    boot_diagnostics_enabled = true
    
    # Extensions
    extensions = [
      "AzureMonitorWindowsAgent",
      "DependencyAgentWindows",
    ]
  }
  
  # ==========================================================================
  # AZURE MONITORING - WEB TIER
  # ==========================================================================
  monitoring_config = {
    # Metrics to collect
    metrics = [
      "Percentage CPU",
      "Network In Total",
      "Network Out Total",
      "Disk Read Operations/Sec",
      "Disk Write Operations/Sec",
    ]
    
    # Alert rules
    alerts = {
      high_cpu = {
        metric_name       = "Percentage CPU"
        operator          = "GreaterThan"
        threshold         = 80
        aggregation       = "Average"
        window_size       = "PT5M"
        frequency         = "PT1M"
        severity          = 2
      }
      high_network_in = {
        metric_name       = "Network In Total"
        operator          = "GreaterThan"
        threshold         = 1073741824  # 1GB
        aggregation       = "Total"
        window_size       = "PT5M"
        frequency         = "PT1M"
        severity          = 3
      }
    }
    
    # Log categories
    log_categories = [
      "ApplicationGatewayAccessLog",
      "ApplicationGatewayPerformanceLog",
      "ApplicationGatewayFirewallLog",
    ]
  }
  
  # ==========================================================================
  # TIER-SPECIFIC TAGS
  # ==========================================================================
  tier_tags = {
    tier           = local.tier_name
    tier_code      = local.tier_code
    tier_order     = tostring(local.tier_order)
    public_facing  = "true"
    waf_protected  = "true"
    ssl_terminated = "true"
  }
}
