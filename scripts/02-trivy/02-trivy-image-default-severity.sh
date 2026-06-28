#!/usr/bin/env bash

trivy image docker-aspnet-apps/sample-api:10 --severity MEDIUM,HIGH,CRITICAL
