#!/usr/bin/env bash

set -euo pipefail
script_dir=$(dirname "$0")

dockerfile="$script_dir/../../src/DockerAspNetApps.SampleApi/Dockerfile"
hadolint --config "$script_dir/../../.hadolint.yaml" "$dockerfile"
