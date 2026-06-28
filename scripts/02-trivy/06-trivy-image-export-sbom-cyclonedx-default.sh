#!/usr/bin/env bash

set -euo pipefail
script_dir=$(dirname "$0")
output_dir="$script_dir/../../temp/trivy-output"
mkdir -p "$output_dir"

trivy image --format cyclonedx --output "$output_dir/sample-api-10-cyclonedx.json" docker-aspnet-apps/sample-api:10
