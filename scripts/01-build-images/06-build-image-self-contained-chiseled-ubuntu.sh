#!/usr/bin/env bash

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
    'self-contained-noble-chiseled'
)

# parameters
no_cache=false
for arg in "$@"; do
    case "$arg" in
        --no-cache)
            no_cache=true
            ;;
        *)
            echo "Unknown argument: $arg"
            echo "Usage: $0 [--no-cache]"
            exit 1
            ;;
    esac
done

# functions
build_image() {
    local dockerfile=$1
    local -n names=$2
    local -n tags=$3
    local no_cache_enabled=$4

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

    docker buildx build \
        --file "$dockerfile" \
        --platform linux/amd64,linux/arm64 \
        "${cache_args[@]}" \
        "${tag_args[@]}" \
        --output type=docker \
        .
}

# build image
pushd $project_dir

echo '🏗️ Crafting container image'
build_image "$dockerfile" image_names imageTags "$no_cache"
echo '🏭 Forged container image'

popd

echo '✅ Script finished!'
