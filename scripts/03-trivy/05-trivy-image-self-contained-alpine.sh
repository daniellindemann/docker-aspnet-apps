#!/usr/bin/env bash

trivy image docker-aspnet-apps/sample-api:10-self-contained-alpine --severity MEDIUM,HIGH,CRITICAL
