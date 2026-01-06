#!/bin/bash
set -e

# -------------------------------------------------
# 0. CONFIGURATION
# -------------------------------------------------
CACHE_DIR="/cache"


HF_TOKEN="${HF_TOKEN:-}"

# -------------------------------------------------
# 1. Install Custom Nodes (unchanged)
# -------------------------------------------------
echo "Installing Custom Nodes..."
cd /comfyui/custom_nodes

function git_clone_and_lock() {
    local url="$1"
    local commit_hash="$2"
    local dir_name=$(basename "$url" .git)
    
    # Clean up previous attempts to ensure we can lock the version safely
    if [ -d "$dir_name" ]; then
        echo "   ♻️  Resetting $dir_name..."
        rm -rf "$dir_name"
    fi

    echo "   ⬇️  Cloning $dir_name..."
    git clone "$url"
    cd "$dir_name"

    # FORCE the specific version
    if [ -n "$commit_hash" ]; then
        echo "   🔒 Locking to specific version: $commit_hash"
        git checkout "$commit_hash"
    fi
    cd ..
}

# --- Essentials & Tools ---
git_clone_and_lock "https://github.com/cristian1980/ComfyUI-Caption-Cleaner.git" ""


/start.sh
