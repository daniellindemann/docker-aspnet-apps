#!/usr/bin/env bash

set -euo pipefail

script_dir=$(dirname "$0")

# script variables
image_to_scan='docker-aspnet-apps/sample-api:10'
report_dir="$script_dir/../../temp/trivy-output"

# functions
message_and_wait() {
    local message="$1"
    echo ""
    echo "$message"
    read -p "Press Enter to continue..."
}

# check if the image exists locally
if ! docker image inspect "$image_to_scan" > /dev/null 2>&1; then
    echo "Image $image_to_scan not found locally. Build it first!"
    exit 1
fi

# ensure trivy is installed
if ! command -v trivy &> /dev/null; then
    echo "Trivy is not installed. Please install Trivy to proceed."
    exit 1
fi

# use trivy to scan the image for os vulnerabilities and show output
message_and_wait "> 1. Scanning the image for OS vulnerabilities using Trivy..."
echo "trivy image --vuln-type os --ignore-unfixed ${image_to_scan}"
trivy image --vuln-type os --ignore-unfixed "$image_to_scan"

# generate scan output
message_and_wait "> 2. Generating scan output for OS vulnerabilities using Trivy..."
echo "trivy image --vuln-type os --ignore-unfixed -f json -o ${report_dir}/trivy-vulnerability-scan-default.json ${image_to_scan}"
mkdir -p "$report_dir"
trivy image --vuln-type os --ignore-unfixed -f json -o "$report_dir/trivy-vulnerability-scan-default.json" "$image_to_scan"
echo "Trivy scan output saved to $report_dir/trivy-vulnerability-scan-default.json"

# patch vulnerabilities using copacetic patch
message_and_wait "> 3. Patching vulnerabilities using copacetic..."
echo "copa patch -r ${report_dir}/trivy-vulnerability-scan-default.json -i ${image_to_scan}"
copa patch -r "$report_dir/trivy-vulnerability-scan-default.json" -i "$image_to_scan"

# check for image
message_and_wait "> 4. Checking for the patched image..."
patched_image="docker-aspnet-apps/sample-api:10-patched"    # because no copa patch -t was specified, the default tag is -patched
echo "docker image ls $patched_image"
docker image ls "$patched_image"

# latest 2 layers of the image
message_and_wait "> 5. Showing the image layer diffs ..."
echo "${image_to_scan}:"
echo "docker image history --format 'table {{.ID}}\t{{.CreatedBy}}\t{{.Size}}' ${image_to_scan} | awk 'NR<=5 {print}'"
docker image history --format 'table {{.ID}}\t{{.CreatedBy}}\t{{.Size}}' "$image_to_scan" | awk 'NR<=5 {print}'
echo "..."
echo "--------------------"
echo "${patched_image}:"
echo "docker image history --format 'table {{.ID}}\t{{.CreatedBy}}\t{{.Size}}' ${patched_image} | awk 'NR<=5 {print}'"
docker image history --format 'table {{.ID}}\t{{.CreatedBy}}\t{{.Size}}' "$patched_image" | awk 'NR<=5 {print}'
echo "..."

# verify the patch
message_and_wait "> 6. Verifying the patch by scanning the patched image for OS vulnerabilities using Trivy..."
echo "trivy image --vuln-type os --ignore-unfixed ${patched_image}"
trivy image --vuln-type os --ignore-unfixed "$patched_image"

# test the image
message_and_wait "> 7. Testing the patched image..."
echo "Run the image by running the following command:"
echo "docker run -it --rm -p 6780:6780 ${patched_image}"
