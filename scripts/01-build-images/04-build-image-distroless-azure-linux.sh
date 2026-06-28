#!/usr/bin/env bash

# Usage:
#   ./04-build-image-distroless-azure-linux.sh [--platform <platform>]
#
# Parameters:
#   --platform <platform>
#     Optional target platform for docker buildx build. By default, the script will build for the host platform.
#     Example values: linux/amd64, linux/arm64.
#
# Examples:
#   ./04-build-image-distroless-azure-linux.sh
#   ./04-build-image-distroless-azure-linux.sh --platform linux/amd64,linux/arm64

set -euo pipefail

script_dir=$(dirname "$0")

# script variables
project_dir=$(realpath "$script_dir/../../src/DockerAspNetApps.SampleApi")
dockerfile=Dockerfile.azure-linux
image_names=(
    'docker-aspnet-apps/sample-api'
    'daniellindemann/docker-aspnet-apps/sample-api'
)
imageTags=(
    '10-azurelinux3.0-distroless'
    '10.0.301-azurelinux3.0-distroless'
    'latest-azurelinux3.0-distroless'
)

# parse arguments
platform_arg=''
while [[ $# -gt 0 ]]; do
    case "$1" in
        --platform)
            if [[ $# -lt 2 ]]; then
                echo 'Error: --platform requires a value' >&2
                exit 1
            fi
            platform_arg="$2"
            shift 2
            ;;
        --platform=*)
            platform_arg="${1#*=}"
            shift
            ;;
        *)
            echo "Error: unknown argument: $1" >&2
            exit 1
            ;;
    esac
done

# functions
build_image() {
    local dockerfile=$1
    local -n names=$2
    local -n tags=$3
    local platform=${4:-}

    local tag_args=()
    for name in "${names[@]}"; do
        for tag in "${tags[@]}"; do
            tag_args+=(--tag "${name}:${tag}")
        done
    done

    # build image
    if [[ -n "$platform" ]]; then
        docker buildx build \
            --file "$dockerfile" \
            --platform "$platform" \
            "${tag_args[@]}" \
            --output type=docker \
            .
    else
        echo ">>> Just do default docker build"
        docker build \
            --file "$dockerfile" \
            "${tag_args[@]}" \
            .
    fi
}

# build image
pushd "$project_dir"

echo '🏗️ Crafting container image'
build_image "$dockerfile" image_names imageTags "$platform_arg"
echo '🏭 Forged container image'

popd

sample_image="${image_names[0]}:${imageTags[0]}"
size_bytes=$(docker image inspect "$sample_image" --format '{{.Size}}')
size_mb=$(awk "BEGIN {printf \"%.2f\", ${size_bytes}/1024/1024}")
echo "📦 Local image size (${sample_image}): ${size_mb} MB (${size_bytes} bytes)"

echo '✅ Script finished!'
