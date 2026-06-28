#!/usr/bin/env bash

set -euo pipefail
script_dir=$(dirname "$0")

dockerfile="$script_dir/../../src/DockerAspNetApps.SampleApi/Dockerfile.architecture-demo"
docker run --rm -i ghcr.io/hadolint/hadolint < "$dockerfile"
