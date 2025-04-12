#!/bin/bash

GLOBAL_BASHRC="/etc/bash.bashrc"
WORKSPACE_PATH="/workspaces/${PWD##*/}"

add_aliases() {
  local bashrc_file=$1

  declare -A aliases=(
    # Docker
    ["d"]="docker"
    ["dps"]="docker ps"
    ["dpsa"]="docker ps -a"
    ["di"]="docker images"
    ["drm"]="docker rm \$(docker ps -aq)"
    ["drmi"]="docker rmi \$(docker images -q)"
    ["dco"]="docker-compose"
    ["dlog"]="docker logs -f"
    ["dbash"]="docker exec -it \$(docker ps -q | head -n 1) bash"

    # Terraform
    ["tf"]="terraform"
    ["tfp"]="terraform plan"
    ["tfa"]="terraform apply"
    ["tfi"]="terraform init"
    ["tfd"]="terraform destroy"
    ["tfv"]="terraform validate"
    ["tff"]="terraform fmt"
    ["tfs"]="terraform show"
    ["tfw"]="terraform workspace"
    ["tfo"]="terraform output"
    ["tfr"]="terraform refresh"

    # Kubernetes
    ["k"]="kubectl"
    ["kctx"]="kubectl config use-context"
    ["kns"]="kubectl config set-context --current --namespace"
    ["kget"]="kubectl get all"
    ["klog"]="kubectl logs -f"
    ["kexec"]="kubectl exec -it"

    # Git
    ["gs"]="git status"
    ["ga"]="git add ."
    ["gc"]="git commit -m"
    ["gp"]="git push"
    ["gpl"]="git pull"
    ["gb"]="git branch"

    # System
    ["c"]="clear"
    ["ll"]="ls -alF"
    ["la"]="ls -A"
    ["l"]="ls -CF"

        # DigitalOcean CLI (doctl)
    ["doa"]="doctl auth init"
    ["dokeys"]="doctl compute ssh-key list"
    ["dosizes"]="doctl compute size list --format Slug,Memory,Disk"
    ["doreg"]="doctl compute region list"
    ["dopjs"]="doctl projects list"
    ["dops"]="doctl compute droplet list"
    ["dopubip"]="doctl compute droplet list --format Name,PublicIPv4"
    ["docr"]="doctl registry list"
    ["dodns"]="doctl compute domain list"
    ["docd"]="doctl compute droplet delete"
    ["docg"]="doctl compute droplet get"


    # Custom workspace alias
    ["login-node"]="cd ${WORKSPACE_PATH}/utils/ && ./login-node.sh"
  )

  for alias_name in "${!aliases[@]}"; do
    if ! grep -q "alias $alias_name=" "$bashrc_file"; then
      echo "alias $alias_name='${aliases[$alias_name]}'" >> "$bashrc_file"
    fi
  done
}

add_aliases $GLOBAL_BASHRC
source $GLOBAL_BASHRC

echo "Global aliases for Docker, Terraform, Kubernetes, Git, and more have been added!"
