#!/bin/bash

install_deps() {
    # ✅ Install mkdocs plugin only if not installed
    if ! pip show mkdocs-awesome-pages-plugin &>/dev/null; then
        echo "Installing mkdocs-awesome-pages-plugin..."
        pip install mkdocs-awesome-pages-plugin
        pip install mkdocs-mermaid2-plugin
        pip install plantuml-markdown

    else
        echo "mkdocs-awesome-pages-plugin already installed."
    fi

    # ✅ Install screen if not present
    if ! dpkg -s screen &>/dev/null; then
        echo "Installing screen..."
        apt-get update
        apt-get install -y screen
    else
        echo "screen already installed."
    fi

    # ✅ Install doctl v1.124.0 if not already or incorrect version
    if ! command -v doctl &>/dev/null || [[ "$(doctl version 2>/dev/null | awk '{print $3}')" != "v1.124.0" ]]; then
        echo "Installing doctl v1.124.0..."
        cd ~
        wget -q https://github.com/digitalocean/doctl/releases/download/v1.124.0/doctl-1.124.0-linux-amd64.tar.gz -O doctl.tar.gz
        tar xf doctl.tar.gz
        sudo mv doctl /usr/local/bin/doctl
        rm -f doctl.tar.gz
    else
        echo "doctl v1.124.0 already installed."
    fi
}

# ✅ Call the function
install_deps
