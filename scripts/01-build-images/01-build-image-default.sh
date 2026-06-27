#!/usr/bin/env bash

set -euo pipefail

script_dir=$(dirname "$0")

# script variables
project_dir=$(realpath "$script_dir/../../src/DockerAspNetApps.SampleApi")
dockerfile=Dockerfile
image_names=(
    'docker-aspnet-apps/sample-api'
    'daniellindemann/docker-aspnet-apps/sample-api'
)
imageTags=(
    '10'
    '10.0.301'
    'latest'
)

# functions
build_image() {
    local dockerfile=$1
    local -n names=$2
    local -n tags=$3

    local tag_args=()
    for name in "${names[@]}"; do
        for tag in "${tags[@]}"; do
            tag_args+=(--tag "${name}:${tag}")
        done
    done

    docker buildx build \
        --file "$dockerfile" \
        --platform linux/amd64,linux/arm64 \
        "${tag_args[@]}" \
        --output type=docker \
        .
}

# build image
pushd $project_dir

echo '🏗️ Crafting container image'
build_image $dockerfile image_names imageTags
echo '🏭 Forged container image'

popd

echo '✅ Script finished!'

