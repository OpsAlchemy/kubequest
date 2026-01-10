# =============================================================================
# AZURE TIER CONFIGURATION - DATA TIER
# =============================================================================
# This file defines tier-specific configurations for the DATA layer.
# Part of the 5-layer configuration hierarchy:
#
#   root.hcl → region.hcl → env.hcl → tier.hcl → terragrunt.hcl
#
# The DATA tier handles:
#   - Azure SQL Database / Managed Instance
#   - Azure Cosmos DB
#   - Azure Cache for Redis
#   - Azure Storage (data lake)
#   - Azure Synapse Analytics
#   - Backup and replication
# =============================================================================

locals {
  # ==========================================================================
  # TIER IDENTIFICATION
  # ==========================================================================
  tier_name        = "data"
  tier_code        = "dat"
  tier_description = "Data persistence tier with databases and storage"
  tier_order       = 3  # Deployment order (last - after web and app)
  
  # ==========================================================================
  # AZURE NETWORKING - DATA TIER
  # ==========================================================================
  subnet_config = {
    address_prefix_size = 24  # /24 = 254 hosts
    
    service_endpoints = [
      "Microsoft.Sql",
      "Microsoft.Storage",
      "Microsoft.KeyVault",
      "Microsoft.AzureCosmosDB",
    ]
    
    # Delegation for SQL Managed Instance (if used)
    delegation = {
      name = "sqlmidelegation"
      service_delegation = {
        name = "Microsoft.Sql/managedInstances"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action",
          "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
          "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
        ]
      }
    }
    
    private_endpoint_network_policies_enabled     = true
    private_link_service_network_policies_enabled = true
  }
  
  # ==========================================================================
  # AZURE NSG RULES - DATA TIER
  # ==========================================================================
  nsg_rules = {
    inbound = [
      {
        name                       = "Allow-AppTier-SQL"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "1433"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "*"
        description                = "Allow SQL from App tier"
      },
      {
        name                       = "Allow-AppTier-PostgreSQL"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5432"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "*"
        description                = "Allow PostgreSQL from App tier"
      },
      {
        name                       = "Allow-AppTier-MySQL"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3306"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "*"
        description                = "Allow MySQL from App tier"
      },
      {
        name                       = "Allow-AppTier-Redis"
        priority                   = 130
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "6379"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "*"
        description                = "Allow Redis from App tier"
      },
      {
        name                       = "Allow-AppTier-CosmosDB"
        priority                   = 140
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges    = ["443", "10255", "10256"]
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "*"
        description                = "Allow Cosmos DB from App tier"
      },
      {
        name                       = "Allow-SQLManagement"
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges    = ["9000", "9003", "1438", "1440", "1452"]
        source_address_prefix      = "SqlManagement"
        destination_address_prefix = "*"
        description                = "Allow SQL MI management"
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
        name                       = "Allow-AzureCloud"
        priority                   = 100
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "AzureCloud"
        description                = "Allow Azure management and backup"
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
        description                = "Allow Azure Storage for backup"
      },
      {
        name                       = "Allow-GeoReplication"
        priority                   = 120
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5022"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
        description                = "Allow SQL geo-replication"
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
  # AZURE SQL DATABASE
  # ==========================================================================
  sql_database_config = {
    # SQL Server settings
    server = {
      version                       = "12.0"
      administrator_login           = "sqladmin"
      minimum_tls_version           = "1.2"
      public_network_access_enabled = false
      
      azuread_administrator = {
        login_username              = "AzureAD Admin"
        azuread_authentication_only = true
      }
      
      identity = {
        type = "SystemAssigned"
      }
    }
    
    # Database settings
    database = {
      collation                   = "SQL_Latin1_General_CP1_CI_AS"
      max_size_gb                 = 250
      read_scale                  = true
      zone_redundant              = true
      geo_backup_enabled          = true
      storage_account_type        = "Geo"
      
      short_term_retention_policy = {
        retention_days           = 35
        backup_interval_in_hours = 12
      }
      
      long_term_retention_policy = {
        weekly_retention  = "P4W"
        monthly_retention = "P12M"
        yearly_retention  = "P5Y"
        week_of_year      = 1
      }
    }
    
    # Threat detection
    threat_detection_policy = {
      state                      = "Enabled"
      email_account_admins       = true
      retention_days             = 90
      disabled_alerts            = []
    }
    
    # Transparent Data Encryption
    tde = {
      state = "Enabled"
    }
    
    # Auditing
    auditing = {
      state                       = "Enabled"
      retention_in_days           = 90
      log_monitoring_enabled      = true
      storage_account_access_key_is_secondary = false
    }
  }
  
  # ==========================================================================
  # AZURE COSMOS DB
  # ==========================================================================
  cosmos_db_config = {
    offer_type = "Standard"
    kind       = "GlobalDocumentDB"
    
    consistency_policy = {
      consistency_level       = "BoundedStaleness"
      max_interval_in_seconds = 300
      max_staleness_prefix    = 100000
    }
    
    geo_location = {
      failover_priority = 0
      zone_redundant    = true
    }
    
    capabilities = [
      "EnableServerless",  # Or remove for provisioned throughput
    ]
    
    backup = {
      type                = "Continuous"
      tier                = "Continuous7Days"
    }
    
    network_acl_bypass_for_azure_services = true
    public_network_access_enabled         = false
    
    # Virtual Network rules (filled from subnet config)
    virtual_network_rules = []
  }
  
  # ==========================================================================
  # AZURE CACHE FOR REDIS
  # ==========================================================================
  redis_config = {
    sku_name            = "Premium"
    family              = "P"
    capacity            = 1
    
    enable_non_ssl_port = false
    minimum_tls_version = "1.2"
    
    redis_configuration = {
      enable_authentication = true
      maxmemory_policy      = "volatile-lru"
      maxmemory_reserved    = 50
      maxmemory_delta       = 50
    }
    
    patch_schedule = [
      {
        day_of_week    = "Sunday"
        start_hour_utc = 2
      },
    ]
    
    zones              = ["1", "2"]
    replicas_per_master = 1
  }
  
  # ==========================================================================
  # AZURE STORAGE (Data Lake)
  # ==========================================================================
  storage_config = {
    account_tier              = "Standard"
    account_replication_type  = "GRS"
    account_kind              = "StorageV2"
    is_hns_enabled            = true  # Hierarchical namespace for Data Lake
    
    min_tls_version                 = "TLS1_2"
    enable_https_traffic_only       = true
    allow_nested_items_to_be_public = false
    shared_access_key_enabled       = false
    default_to_oauth_authentication = true
    
    blob_properties = {
      versioning_enabled       = true
      change_feed_enabled      = true
      last_access_time_enabled = true
      
      delete_retention_policy = {
        days = 30
      }
      
      container_delete_retention_policy = {
        days = 30
      }
    }
    
    network_rules = {
      default_action             = "Deny"
      bypass                     = ["AzureServices", "Logging", "Metrics"]
      virtual_network_subnet_ids = []
    }
  }
  
  # ==========================================================================
  # AZURE MONITORING - DATA TIER
  # ==========================================================================
  monitoring_config = {
    # SQL metrics
    sql_metrics = [
      "cpu_percent",
      "physical_data_read_percent",
      "log_write_percent",
      "dtu_consumption_percent",
      "storage_percent",
      "workers_percent",
      "sessions_percent",
      "deadlock",
    ]
    
    # Cosmos DB metrics
    cosmos_metrics = [
      "TotalRequests",
      "TotalRequestUnits",
      "ProvisionedThroughput",
      "AvailableStorage",
      "DocumentCount",
    ]
    
    # Redis metrics
    redis_metrics = [
      "percentProcessorTime",
      "usedmemory",
      "usedmemorypercentage",
      "connectedclients",
      "cacheHits",
      "cacheMisses",
      "evictedkeys",
    ]
    
    alerts = {
      sql_high_dtu = {
        metric_name = "dtu_consumption_percent"
        operator    = "GreaterThan"
        threshold   = 90
        aggregation = "Average"
        window_size = "PT5M"
        frequency   = "PT1M"
        severity    = 2
      }
      sql_deadlock = {
        metric_name = "deadlock"
        operator    = "GreaterThan"
        threshold   = 0
        aggregation = "Count"
        window_size = "PT5M"
        frequency   = "PT1M"
        severity    = 1
      }
      cosmos_throttled = {
        metric_name = "TotalRequests"
        operator    = "GreaterThan"
        threshold   = 1000
        aggregation = "Count"
        window_size = "PT5M"
        frequency   = "PT1M"
        severity    = 2
      }
      redis_high_memory = {
        metric_name = "usedmemorypercentage"
        operator    = "GreaterThan"
        threshold   = 90
        aggregation = "Average"
        window_size = "PT5M"
        frequency   = "PT1M"
        severity    = 2
      }
    }
    
    log_categories = [
      "SQLSecurityAuditEvents",
      "SQLInsights",
      "AutomaticTuning",
      "QueryStoreRuntimeStatistics",
      "QueryStoreWaitStatistics",
      "Errors",
      "DatabaseWaitStatistics",
      "Timeouts",
      "Blocks",
      "Deadlocks",
    ]
  }
  
  # ==========================================================================
  # TIER-SPECIFIC TAGS
  # ==========================================================================
  tier_tags = {
    tier                = local.tier_name
    tier_code           = local.tier_code
    tier_order          = tostring(local.tier_order)
    public_facing       = "false"
    contains_pii        = "true"
    requires_encryption = "true"
    backup_required     = "true"
    dr_required         = "true"
  }
}
