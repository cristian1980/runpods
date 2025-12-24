#!/bin/bash

# Stop the script if any command fails
set -e

# 0. CONFIGURATION
# ------------------------------------------------------------------------------
# Define a cache directory. We will mount this from Windows later.
CACHE_DIR="/cache"
echo "Creating cache directory if it doesn't exist at: $CACHE_DIR"
mkdir -p "$CACHE_DIR"

# HELPER FUNCTION: Download only if not cached
function provision_model() {
    local url="$1"
    local filename="$2"
    local target_dir="$3"

    # Create target directory
    mkdir -p "$target_dir"
    
    local cache_path="$CACHE_DIR/$filename"
    local target_path="$target_dir/$filename"

    echo "Checking model: $filename"

    # 1. Check if it is already installed in ComfyUI (Skip everything)
    if [ -f "$target_path" ]; then
        echo "   ✅ Model already exists in ComfyUI. Skipping."
        return
    fi

    # 2. Check if it is in the Local Cache (Copy it)
    if [ -f "$cache_path" ]; then
        echo "   ♻️  Found in Cache! Copying to target..."
        cp "$cache_path" "$target_path"
        return
    fi

    # 3. If neither, Download to Cache first, then Copy
    echo "   ⬇️  Downloading to Cache..."
    # We use -O to name the file explicitly in the cache
    wget -q --show-progress -O "$cache_path" "$url"
    
    echo "   📋 Copying from Cache to Target..."
    cp "$cache_path" "$target_path"
}

# 1. Install Custom Nodes
# ------------------------------------------------------------------------------
echo "Installing Custom Nodes..."
cd /comfyui/custom_nodes

# Helper to git clone or pull if exists (so it doesn't crash on re-runs)
function git_clone_or_pull() {
    local url="$1"
    local dir_name=$(basename "$url" .git)
    
    if [ -d "$dir_name" ]; then
        echo "   Updating $dir_name..."
        cd "$dir_name" && git pull && cd ..
    else
        echo "   Cloning $dir_name..."
        git clone "$url"
    fi
}

git_clone_or_pull "https://github.com/cubiq/ComfyUI_essentials"
git_clone_or_pull "https://github.com/yolain/ComfyUI-Easy-Use"
git_clone_or_pull "https://github.com/chflame163/ComfyUI_LayerStyle"
git_clone_or_pull "https://github.com/TemryL/ComfyS3"

# 2. Download Models (Using the Cache Function)
# ------------------------------------------------------------------------------
echo "Provisioning Models..."

# Z-Image Turbo
provision_model \
    "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/diffusion_models/z_image_turbo_bf16.safetensors" \
    "z_image_turbo_bf16.safetensors" \
    "/comfyui/models/diffusion_models"

# Qwen 3.4B
provision_model \
    "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors" \
    "qwen_3_4b.safetensors" \
    "/comfyui/models/text_encoders"

# FLUX VAE
provision_model \
    "https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/ae.safetensors" \
    "ae.safetensors" \
    "/comfyui/models/vae"

# Florence-2 Large
provision_model \
    "https://huggingface.co/microsoft/Florence-2-large/resolve/main/model.safetensors" \
    "florence2-large.safetensors" \
    "/comfyui/models/LLM"


# 3. Install Python Dependencies
# ------------------------------------------------------------------------------
echo "Installing Python Dependencies..."

# We force these. If they fail, the script exits (because of set -e at the top)
pip install -r /comfyui/custom_nodes/ComfyUI_LayerStyle/requirements.txt
pip install -r /comfyui/custom_nodes/ComfyUI-Easy-Use/requirements.txt
pip install -r /comfyui/custom_nodes/ComfyS3/requirements.txt

# Optional: Check for ComfyUI_essentials (it sometimes has one too)
pip install -r /comfyui/custom_nodes/ComfyUI_essentials/requirements.txt

echo "✅ Provisioning Complete!"
cd /comfyui
