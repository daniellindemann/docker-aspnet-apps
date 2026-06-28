#!/usr/bin/env bash

set -euo pipefail
script_dir=$(dirname "$0")
output_dir="$script_dir/../../temp/trivy-output"
mkdir -p "$output_dir"

# default spdx
trivy image --format spdx --output "$output_dir/sample-api-10-alpine-spdx.spdx" docker-aspnet-apps/sample-api:10-alpine
# spdx-json (https://trivy.dev/docs/latest/supply-chain/sbom/#spdx)
trivy image --format spdx-json --output "$output_dir/sample-api-10-alpine-spdx-json.spdx" docker-aspnet-apps/sample-api:10-alpine
