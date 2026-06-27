#!/usr/bin/env bash

set -euo pipefail

script_dir=$(dirname "$0")

# variables
image_search_string='sample-api'
dry_run=false

usage() {
	echo "Usage: $(basename "$0") [--dry-run|-n]"
}

while [[ $# -gt 0 ]]; do
	case "$1" in
		--dry-run|-n)
			dry_run=true
			shift
			;;
		--help|-h)
			usage
			exit 0
			;;
		*)
			echo "Unknown option: $1"
			usage
			exit 1
			;;
	esac
done

# Get unique image references (repository:tag) whose repository contains the search string.
mapfile -t image_refs < <(
	docker image ls --format '{{.Repository}}:{{.Tag}}' \
		| awk -v needle="$image_search_string" 'index($0, needle) > 0' \
		| awk '!seen[$0]++'
)

if [[ ${#image_refs[@]} -eq 0 ]]; then
	echo "No Docker images found containing '$image_search_string'."
	exit 0
fi

if [[ "$dry_run" == true ]]; then
	echo "[DRY RUN] Would delete ${#image_refs[@]} image(s) containing '$image_search_string':"
	for image_ref in "${image_refs[@]}"; do
		echo "Would delete: $image_ref"
	done
	exit 0
fi

echo "Deleting ${#image_refs[@]} image(s) containing '$image_search_string':"

for image_ref in "${image_refs[@]}"; do
	docker image rm "$image_ref" >/dev/null
	echo "Deleted: $image_ref"
done
