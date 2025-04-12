#!/bin/bash



function main() {
    echo "Starting the main setup process..."

    echo "Adding vscode user to the Docker group..."
    sudo usermod -aG docker vscode

    WORKSPACE_PATH="/workspaces/${PWD##*/}"

    echo "Making scripts executable..."
    chmod +x "${WORKSPACE_PATH}/.devcontainer/scripts/install-deps.sh"
    chmod +x "${WORKSPACE_PATH}/.devcontainer/scripts/set-env.sh"
    chmod +x "${WORKSPACE_PATH}/.devcontainer/scripts/set-aliases.sh"

    echo "Running the script to install dependencies..."
    bash "${WORKSPACE_PATH}/.devcontainer/scripts/install-deps.sh"
    bash "${WORKSPACE_PATH}/.devcontainer/scripts/set-env.sh"
    bash "${WORKSPACE_PATH}/.devcontainer/scripts/set-aliases.sh"

    echo "Main setup process completed!"
}

main
