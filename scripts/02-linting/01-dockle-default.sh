#!/usr/bin/env bash

set -euo pipefail
script_dir=$(dirname "$0")
image='docker-aspnet-apps/sample-api:10'

dockle --exit-code 1 --exit-level warn "$image"
