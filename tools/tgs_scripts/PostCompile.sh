#!/bin/bash
# TGS passes the deployment directory as the first argument.
# iconforge regenerates spritesheets from disk after cache invalidation (e.g. upstream merges).
# Ensure modular icon trees are present in the deployment folder.
set -e
set -x

DEPLOY_DIR="$1"
cd "$DEPLOY_DIR"
tools/deploy.sh "$DEPLOY_DIR"
