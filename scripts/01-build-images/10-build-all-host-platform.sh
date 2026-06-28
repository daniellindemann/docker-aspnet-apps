#!/usr/bin/env bash

set -euo pipefail
script_dir=$(dirname "$0")

"$script_dir/01-build-image-default.sh"
"$script_dir/02-build-image-alpine.sh"
"$script_dir/03-build-image-distroless-chiseled-ubuntu.sh"
"$script_dir/04-build-image-distroless-azure-linux.sh"
"$script_dir/05-build-image-self-contained-alpine.sh"
"$script_dir/06-build-image-self-contained-chiseled-ubuntu.sh"
