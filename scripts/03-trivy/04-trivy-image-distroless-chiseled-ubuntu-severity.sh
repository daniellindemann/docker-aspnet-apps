#!/usr/bin/env bash

trivy image docker-aspnet-apps/sample-api:10-noble-chiseled --severity MEDIUM,HIGH,CRITICAL
