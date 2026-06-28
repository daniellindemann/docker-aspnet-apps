#!/usr/bin/env bash

# Usage:
#   ./06-build-image-self-contained-chiseled-ubuntu.sh [--no-cache] [--multi-platform]
#
# Parameters:
#   --no-cache
#     Optional flag to disable the Docker build cache.
#
#   --multi-platform
#     Optional flag to build for both linux/amd64 and linux/arm64.
#     By default, the script builds only for the host platform.
#
# Examples:
#   ./06-build-image-self-contained-chiseled-ubuntu.sh
#   ./06-build-image-self-contained-chiseled-ubuntu.sh --no-cache
#   ./06-build-image-self-contained-chiseled-ubuntu.sh --multi-platform
#   ./06-build-image-self-contained-chiseled-ubuntu.sh --no-cache --multi-platform

set -euo pipefail

script_dir=$(dirname "$0")

# script variables
project_dir=$(realpath "$script_dir/../../src/DockerAspNetApps.SampleApi")
dockerfile=Dockerfile.self-contained-chiseled-ubuntu
image_names=(
    'docker-aspnet-apps/sample-api'
    'daniellindemann/docker-aspnet-apps/sample-api'
)
imageTags=(
    '10-self-contained-noble-chiseled'
    '10.0.301-self-contained-noble-chiseled'
    'latest-self-contained-noble-chiseled'
)

# parameters
no_cache=false
multi_platform=false
for arg in "$@"; do
    case "$arg" in
        --no-cache)
            no_cache=true
            ;;
        --multi-platform)
            multi_platform=true
            ;;
        *)
            echo "Unknown argument: $arg"
            echo "Usage: $0 [--no-cache] [--multi-platform]"
            exit 1
            ;;
    esac
done

# functions
detect_host_platform() {
    local machine
    machine=$(uname -m)

    case "$machine" in
        x86_64|amd64)
            echo "linux/amd64"
            ;;
        aarch64|arm64)
            echo "linux/arm64"
            ;;
        *)
            echo "linux/amd64"
            ;;
    esac
}

build_image() {
    local dockerfile=$1
    local -n names=$2
    local -n tags=$3
    local no_cache_enabled=$4
    local is_multi_platform=$5

    local tag_args=()
    for name in "${names[@]}"; do
        for tag in "${tags[@]}"; do
            tag_args+=(--tag "${name}:${tag}")
        done
    done

    local cache_args=()
    if [[ "$no_cache_enabled" == "true" ]]; then
        cache_args+=(--no-cache)
    fi

    local host_platform
    host_platform=$(detect_host_platform)

    local other_platform='linux/amd64'
    if [[ "$host_platform" == "linux/amd64" ]]; then
        other_platform='linux/arm64'
    fi

    local platforms="$host_platform"
    if [[ "$is_multi_platform" == "true" ]]; then
        platforms="${host_platform},${other_platform}"
        echo "Info: Building with platforms: ${platforms}."
    fi

    # local output_args=()
    # if [[ "$is_multi_platform" == "true" ]]; then
    #     output_args=(--output type=docker)
    # fi

    docker buildx build \
        --file "$dockerfile" \
        --platform "$platforms" \
        "${cache_args[@]}" \
        "${tag_args[@]}" \
        --output type=docker \
        .
}

# build image
pushd "$project_dir"

echo '🏗️ Crafting container image'
build_image "$dockerfile" image_names imageTags "$no_cache" "$multi_platform"
echo '🏭 Forged container image'

popd

sample_image="${image_names[0]}:${imageTags[0]}"
size_bytes=$(docker image inspect "$sample_image" --format '{{.Size}}')
size_mb=$(awk "BEGIN {printf \"%.2f\", ${size_bytes}/1024/1024}")
echo "📦 Local image size (${sample_image}): ${size_mb} MB (${size_bytes} bytes)"

echo '✅ Script finished!'
