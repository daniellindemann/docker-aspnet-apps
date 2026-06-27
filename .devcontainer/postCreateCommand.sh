#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
# Treat unset variables as an error and exit
# Return the exit status of the last command in a pipeline that failed
set -euo pipefail

script_dir=$(dirname "$0")

# ensure docker builder with arm64 support is available
ensure_docker_buildx_builder() {
    builderName='mybuilder'

    if ! command -v docker &> /dev/null; then
        echo "Docker CLI not found, skipping buildx builder setup"
        return
    fi

    if ! docker buildx version &> /dev/null; then
        echo "Docker buildx is not available, skipping builder setup"
        return
    fi

    if docker buildx ls --format '{{.Name}}' | grep -qx "$builderName"; then
        echo "Docker buildx builder '${builderName}' already exists"
        docker buildx use $builderName
        return
    fi

    echo "Docker buildx builder '${builderName}' not found. Creating it"
    docker buildx create --name "${builderName}" --use --bootstrap --platform linux/amd64,linux/arm64
}
ensure_docker_buildx_builder

# ensure temp directory exists
ensure_temp_dir() {
    if [ ! -d "$script_dir/.temp" ]; then
        mkdir -p "$script_dir/.temp"
    fi
}
ensure_temp_dir

# ensure permissions in home directory
sudo chown -R "$(whoami)" "$HOME"

# install tools
IS_ARM=$(if [[ $(uname -m) == 'aarch64' || $(uname -m) == "arm64" ]]; then echo true; else echo false; fi)

# > dockle
echo "--- Install dockle ---"


# check if dockle is already installed
if command -v dockle &> /dev/null; then
    echo "dockle is already installed, skipping installation"
else
    echo "dockle is not installed, proceeding with installation"
    # check if file dockle.deb exists in .temp directory
    if [ -f "$script_dir/.temp/dockle.deb" ]; then
        echo "dockle.deb already exists in .temp directory, skipping download"
    else
        echo "Downloading dockle.deb to .temp directory"
        DOCKLE_DOWNLOAD_FILE_SUFFIX=$(if [[ $IS_ARM = true ]]; then echo 'Linux-ARM64'; else echo 'Linux-64bit'; fi)
        DOCKLE_VERSION=$(
            curl --silent "https://api.github.com/repos/goodwithtech/dockle/releases/latest" | \
            grep '"tag_name":' | \
            sed -E 's/.*"v([^"]+)".*/\1/' \
        ) && curl -L -o "$script_dir/.temp/dockle.deb" "https://github.com/goodwithtech/dockle/releases/download/v${DOCKLE_VERSION}/dockle_${DOCKLE_VERSION}_${DOCKLE_DOWNLOAD_FILE_SUFFIX}.deb"
    fi

    # final install
    echo "Installing dockle from .temp/dockle.deb"
    sudo dpkg -i "$script_dir/.temp/dockle.deb"
fi
echo ""

# > hadolint
echo "--- Install hadolint ---"

# check if hadolint is already installed
if command -v hadolint &> /dev/null; then
    echo "hadolint is already installed, skipping installation"
else
    echo "hadolint is not installed, proceeding with installation"
    # check if file hadolint exists in .temp directory
    if [ -f "$script_dir/.temp/hadolint" ]; then
        echo "hadolint already exists in .temp directory, skipping download"
    else
        echo "Downloading hadolint to .temp directory"
        HADOLINT_DOWNLOAD_FILE_SUFFIX=$(if [[ $IS_ARM = true ]]; then echo 'linux-arm64'; else echo 'linux-x86_64'; fi)
        HADOLINT_VERSION=$(
            curl --silent "https://api.github.com/repos/hadolint/hadolint/releases/latest" | \
            grep '"tag_name":' | \
            sed -E 's/.*"v([^"]+)".*/\1/' \
        ) && curl -L -o "$script_dir/.temp/hadolint" "https://github.com/hadolint/hadolint/releases/download/v${HADOLINT_VERSION}/hadolint-${HADOLINT_DOWNLOAD_FILE_SUFFIX}" && chmod +x "$script_dir/.temp/hadolint"
    fi

    # final install
    echo "Installing hadolint from .temp/hadolint"
    sudo cp "$script_dir/.temp/hadolint" /usr/local/bin
fi
echo ""

# > trivy
echo "--- Install trivy ---"

# check if trivy is already installed
if command -v trivy &> /dev/null; then
    echo "trivy is already installed, skipping installation"
else
    echo "trivy is not installed, proceeding with installation"
    # check if file trivy exists in .temp directory
    if [ -f "$script_dir/.temp/trivy.deb" ]; then
        echo "trivy already exists in .temp directory, skipping download"
    else
        echo "Downloading trivy to .temp directory"
        TRIVY_DOWNLOAD_FILE_SUFFIX=$(if [[ $IS_ARM = true ]]; then echo 'Linux-ARM64'; else echo 'Linux-64bit'; fi)
        TRIVY_VERSION=$(
            curl --silent "https://api.github.com/repos/aquasecurity/trivy/releases/latest" | \
            grep '"tag_name":' | \
            sed -E 's/.*"v([^"]+)".*/\1/' \
        ) && curl -L -o "$script_dir/.temp/trivy.deb" "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_${TRIVY_DOWNLOAD_FILE_SUFFIX}.deb"
    fi

    # final install
    echo "Installing trivy from .temp/trivy.deb"
    sudo dpkg -i "$script_dir/.temp/trivy.deb"
fi
echo ""

# > copacetic
echo "--- Install copacetic ---"

# check if copacetic is already installed
if command -v copa &> /dev/null; then
    echo "copacetic is already installed, skipping installation"
else
    echo "copa is not installed, proceeding with installation"
    # check if file copacetic exists in .temp directory
    if [ -f "$script_dir/.temp/copa" ]; then
        echo "copacetic already exists in .temp directory, skipping download"
    else
        echo "Downloading copacetic to .temp directory"
        COPACETIC_DOWNLOAD_FILE_SUFFIX=$(if [[ $IS_ARM = true ]]; then echo 'linux_arm64'; else echo 'linux_amd64'; fi)
        COPACETIC_VERSION=$(
            curl --silent "https://api.github.com/repos/project-copacetic/copacetic/releases/latest" | \
            grep '"tag_name":' | \
            sed -E 's/.*"v([^"]+)".*/\1/' \
        ) && curl -L -o "$script_dir/.temp/copa.tar.gz" "https://github.com/project-copacetic/copacetic/releases/download/v${COPACETIC_VERSION}/copa_${COPACETIC_VERSION}_${COPACETIC_DOWNLOAD_FILE_SUFFIX}.tar.gz" \
            && tar -xvzf "$script_dir/.temp/copa.tar.gz" -C "$script_dir/.temp" copa && chmod +x "$script_dir/.temp/copa" && rm "$script_dir/.temp/copa.tar.gz"
    fi

    # final install
    echo "Installing copacetic from .temp/copa"
    sudo cp "$script_dir/.temp/copa" /usr/local/bin
fi
echo ""

# > notation
echo "--- Install notation ---"

# check if notation is already installed
if command -v notation &> /dev/null; then
    echo "notation is already installed, skipping installation"
else
    echo "notation is not installed, proceeding with installation"
    # check if file notation exists in .temp directory
    if [ -f "$script_dir/.temp/notation" ]; then
        echo "notation already exists in .temp directory, skipping download"
    else
        echo "Downloading notation to .temp directory"
        NOTATION_DOWNLOAD_FILE_SUFFIX=$(if [[ $IS_ARM = true ]]; then echo 'linux_arm64'; else echo 'linux_amd64'; fi)
        NOTATION_VERSION=$(
            curl --silent "https://api.github.com/repos/notaryproject/notation/releases/latest" | \
            grep '"tag_name":' | \
            sed -E 's/.*"v([^"]+)".*/\1/' \
        ) && curl -L -o "$script_dir/.temp/notation.tar.gz" "https://github.com/notaryproject/notation/releases/download/v${NOTATION_VERSION}/notation_${NOTATION_VERSION}_${NOTATION_DOWNLOAD_FILE_SUFFIX}.tar.gz" \
            && tar -xvzf "$script_dir/.temp/notation.tar.gz" -C "$script_dir/.temp" notation && chmod +x "$script_dir/.temp/notation" && rm "$script_dir/.temp/notation.tar.gz"
    fi

    # final install
    echo "Installing notation from .temp/notation"
    sudo cp "$script_dir/.temp/notation" /usr/local/bin
fi
echo ""

# > notation plugin azure-kv
echo "--- Install notation plugin azure-kv ---"

# check if notation plugin azure-kv is already installed
if command -v notation &> /dev/null && notation plugin list | grep -q "azure-kv"; then
    echo "notation plugin azure-kv is already installed, skipping installation"
else
    echo "notation plugin azure-kv is not installed, proceeding with installation"
    # check if file notation exists in .temp directory
    if [ -f "$script_dir/.temp/notation-azure-kv" ]; then
        echo "notation plugin azure-kv already exists in .temp directory, skipping download"
    else
        echo "Downloading notation plugin azure-kv to .temp directory"
        NOTATION_KV_DOWNLOAD_FILE_SUFFIX=$(if [[ $IS_ARM = true ]]; then echo 'linux_arm64'; else echo 'linux_amd64'; fi)
        NOTATION_KV_VERSION=$(
            curl --silent "https://api.github.com/repos/Azure/notation-azure-kv/releases/latest" | \
            grep '"tag_name":' | \
            sed -E 's/.*"v([^"]+)".*/\1/' \
        ) && curl -L -o "$script_dir/.temp/notation-azure-kv.tar.gz" "https://github.com/Azure/notation-azure-kv/releases/download/v${NOTATION_KV_VERSION}/notation-azure-kv_${NOTATION_KV_VERSION}_${NOTATION_KV_DOWNLOAD_FILE_SUFFIX}.tar.gz" \
            && tar -xvzf "$script_dir/.temp/notation-azure-kv.tar.gz" -C "$script_dir/.temp" notation-azure-kv && chmod +x "$script_dir/.temp/notation-azure-kv" && rm "$script_dir/.temp/notation-azure-kv.tar.gz"
    fi

    # final install
    echo "Installing notation plugin azure-kv from .temp/notation-azure-kv"
    mkdir -p "${HOME}/.config/notation/plugins/azure-kv"
    cp "$script_dir/.temp/notation-azure-kv" "${HOME}/.config/notation/plugins/azure-kv"
fi
echo ""

# azure stuff

# > use latest version of azure cli
az bicep upgrade

# dotnet stuff

# > update dotnet workloads
sudo dotnet workload update

# > install dotnet tools
dotnet tool restore

# > restore and build projects
dotnet restore && dotnet build --no-restore

echo "✅ Post-create command completed successfully."
