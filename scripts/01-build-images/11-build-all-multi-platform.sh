#!/usr/bin/env bash

set -euo pipefail
script_dir=$(dirname "$0")

# variables
platforms='linux/amd64,linux/arm64'

"$script_dir/01-build-image-default.sh" --platform "$platforms"
"$script_dir/02-build-image-alpine.sh" --platform "$platforms"
"$script_dir/03-build-image-distroless-chiseled-ubuntu.sh" --platform "$platforms"
"$script_dir/04-build-image-distroless-azure-linux.sh" --platform "$platforms"
"$script_dir/05-build-image-self-contained-alpine.sh" --multi-platform
"$script_dir/06-build-image-self-contained-chiseled-ubuntu.sh" --multi-platform
