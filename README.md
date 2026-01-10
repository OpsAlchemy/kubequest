# Terragrunt Demo Project

This is a working Terragrunt project that demonstrates best practices for organizing infrastructure as code.

## Project Structure

```
terragrunt-01/
├── terragrunt.hcl              # Root configuration (inherited by all modules)
├── modules/                     # Reusable Terraform modules
│   └── app/                    # Example application module
│       ├── main.tf
│       └── versions.tf
├── environments/               # Environment-specific configurations
│   ├── dev/
│   │   └── app/
│   │       └── terragrunt.hcl
│   ├── staging/
│   │   └── app/
│   │       └── terragrunt.hcl
│   └── prod/
│       └── app/
│           └── terragrunt.hcl
└── README.md
```

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.0
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/) >= 0.38

### Install Terragrunt (if not already installed)

```bash
# On Linux
wget https://github.com/gruntwork-io/terragrunt/releases/download/v0.54.8/terragrunt_linux_amd64
chmod +x terragrunt_linux_amd64
sudo mv terragrunt_linux_amd64 /usr/local/bin/terragrunt

# Or using package manager
# Ubuntu/Debian
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terragrunt
```

## How to Use

### 1. Initialize and Apply a Single Environment

```bash
# Navigate to the dev environment
cd environments/dev/app

# Initialize Terragrunt (downloads modules and providers)
terragrunt init

# Plan the changes
terragrunt plan

# Apply the changes
terragrunt apply
```

### 2. Work with Multiple Environments

```bash
# From the root directory, run commands for all environments
cd /home/vagabond/dev/terragrunt-01

# Plan all environments
terragrunt run-all plan

# Apply changes to all environments
terragrunt run-all apply

# Destroy all environments
terragrunt run-all destroy
```

### 3. Work with Specific Environment

```bash
# Dev environment
cd environments/dev/app
terragrunt apply

# Staging environment
cd environments/staging/app
terragrunt apply

# Production environment
cd environments/prod/app
terragrunt apply
```

## Key Features

### DRY Configuration
- **Root terragrunt.hcl**: Contains common configuration inherited by all environments
- **Module reuse**: The same Terraform module is used across environments
- **Environment-specific inputs**: Each environment can override variables

### Remote State Management
- Configured for local backend (can be easily changed to S3, GCS, etc.)
- Automatic state file organization by environment
- State isolation between environments

### Benefits of This Structure

1. **Don't Repeat Yourself (DRY)**: Common configuration is defined once
2. **Environment Isolation**: Each environment has its own state file
3. **Scalability**: Easy to add new environments or modules
4. **Consistency**: Same module code runs everywhere with different inputs
5. **Safety**: Can test changes in dev before promoting to prod

## Common Commands

```bash
# Initialize
terragrunt init

# Validate configuration
terragrunt validate

# Plan changes
terragrunt plan

# Apply changes
terragrunt apply

# Show current state
terragrunt show

# Destroy resources
terragrunt destroy

# Run command in all subdirectories
terragrunt run-all [command]

# Format HCL files
terragrunt hclfmt
```

## Customization

### Add a New Environment

1. Create a new directory under `environments/`
2. Copy an existing `terragrunt.hcl` file
3. Update the `environment` input variable

### Add a New Module

1. Create a new directory under `modules/`
2. Write your Terraform code
3. Reference it from environment-specific `terragrunt.hcl` files

### Change Backend to S3

Update the root `terragrunt.hcl` file:

```hcl
remote_state {
  backend = "s3"
  config = {
    bucket         = "my-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
```

## Next Steps

1. Install Terragrunt if you haven't already
2. Navigate to `environments/dev/app`
3. Run `terragrunt init` then `terragrunt apply`
4. Explore the outputs and state files
5. Customize the modules for your use case

## Troubleshooting

- **Module not found**: Run `terragrunt init` to download the module
- **State locked**: Another process may be running; wait or remove the lock
- **Version mismatch**: Ensure Terraform and Terragrunt versions meet requirements

## Learn More

- [Terragrunt Documentation](https://terragrunt.gruntwork.io/docs/)
- [Terraform Documentation](https://www.terraform.io/docs/)
- [Best Practices](https://terragrunt.gruntwork.io/docs/getting-started/quick-start/)
