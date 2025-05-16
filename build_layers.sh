#!/bin/bash

set -e

# Python version (change here as needed)
PYTHON_VERSION="3.11"

# Construct docker image based on python version
DOCKER_IMAGE="public.ecr.aws/sam/build-python${PYTHON_VERSION}"

# Usage
usage() {
  echo "Usage: $0 <platform1> [<platform2> ...]"
  echo "Example: $0 manylinux2014_aarch64 manylinux2014_x86_64"
  exit 1
}

# Check platforms passed
if [ "$#" -lt 1 ]; then
  usage
fi

PLATFORMS=("$@")
LAYER_DIR="$(pwd)/lambda_layers"
OUTPUT_DIR="$(pwd)/built_lambda_layers"

# Read pre-package commands file
PRE_PACKAGE_CMDS_FILE="$LAYER_DIR/layer/pre-package-commands.txt"

if [ ! -f "$PRE_PACKAGE_CMDS_FILE" ]; then
  echo "Warning: no pre-package commands file not found at $PRE_PACKAGE_CMDS_FILE"
else
  # Parse and clean commands from file to inject into docker command
  PRE_PACKAGE_CMDS=$(sed -e 's/^\s*"//' -e 's/",\s*$//' -e 's,//.*$,,' "$PRE_PACKAGE_CMDS_FILE" | tr '\n' ';')
fi

mkdir -p "$OUTPUT_DIR"

for LAYER_PATH in "$LAYER_DIR"/*/; do
  [ -d "$LAYER_PATH" ] || continue

  ABS_LAYER_PATH="$(realpath "$LAYER_PATH")"
  LAYER_NAME=$(basename "$LAYER_PATH")
  echo "🔨 Building layer: $LAYER_NAME"

  for PLATFORM in "${PLATFORMS[@]}"; do
    echo "➡️  Platform: $PLATFORM"

    ZIP_NAME="layer-${LAYER_NAME}-${PLATFORM}-py${PYTHON_VERSION}.zip"
    ZIP_PATH="$OUTPUT_DIR/$ZIP_NAME"

    if [ -f "$ZIP_PATH" ]; then
      echo "⚠️  Skipping build, file already exists: $ZIP_NAME"
      continue
    fi

    docker run --rm \
      -v "$ABS_LAYER_PATH":/asset-input \
      -v "$OUTPUT_DIR":/asset-output \
      -w /asset-input \
      "$DOCKER_IMAGE" \
      bash -c '
        set -e
        python -m venv /tmp/venv && \
        mkdir -p /tmp/pip-cache && chmod -R 777 /tmp/pip-cache && \
        export PIP_CACHE_DIR=/tmp/pip-cache && \
        export PATH="/tmp/venv/bin:$PATH" && \
        pip install --platform '"$PLATFORM"' --only-binary=:all: \
          -r requirements.txt -t /asset-output/python && \
        '"${PRE_PACKAGE_CMDS:-true}"' && \
        cd /asset-output && \
        zip -r '"$ZIP_NAME"' python && \
        rm -rf /asset-output/python
      '

    echo "✅ Built: built_lambda_layers/$ZIP_NAME"
  done
done

echo "🎉 All layers built successfully!"
