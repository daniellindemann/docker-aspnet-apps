#!/usr/bin/env bash

set -euo pipefail
script_dir=$(dirname "$0")
image='docker-aspnet-apps/sample-api:10-self-contained-alpine'

dockle --exit-code 1 --exit-level warn "$image"
