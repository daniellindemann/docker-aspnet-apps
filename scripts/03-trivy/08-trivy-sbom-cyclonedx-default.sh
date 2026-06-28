#!/usr/bin/env bash

set -euo pipefail
script_dir=$(dirname "$0")
input_dir="$script_dir/../../temp/trivy-output"

# https://trivy.dev/docs/latest/target/sbom/
echo "ensure script 06-trivy-image-export-sbom-cyclonedx-default.sh is run first to generate cyclonedx sbom"
trivy sbom "$input_dir/sample-api-10-cyclonedx.json"
