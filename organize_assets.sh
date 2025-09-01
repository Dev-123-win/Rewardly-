#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# Source and destination directories
SRC_MODELS="temp_assets/assets/models"
SRC_SOUNDS="temp_assets/assets/sounds"
DEST_ASSETS="endless_runner_game/assets"
DEST_SOUNDS="endless_runner_game/assets/sounds"

# Create destination directories
mkdir -p "$DEST_SOUNDS"

# Copy models
cp "$SRC_MODELS/jake.glb" "$DEST_ASSETS/"
cp "$SRC_MODELS/train.glb" "$DEST_ASSETS/"
cp "$SRC_MODELS/barrier.glb" "$DEST_ASSETS/"
cp "$SRC_MODELS/coin.glb" "$DEST_ASSETS/"

# Copy sounds
cp "$SRC_SOUNDS/coin.mp3" "$DEST_SOUNDS/"
cp "$SRC_SOUNDS/game-over.mp3" "$DEST_SOUNDS/"

echo "Assets copied successfully!"
