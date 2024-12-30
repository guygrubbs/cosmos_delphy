#!/bin/bash

# deploy.sh - Deployment script for DELPHY COSMOS Tools
# Author: DELPHY Operations Team
# Version: 1.0.0
# Last Updated: 2024-12-30

set -e  # Exit immediately if a command exits with a non-zero status
set -o pipefail  # Treat errors in pipelines correctly

# --------------------------------------------
# CONFIGURATION
# --------------------------------------------
DEPLOY_TARGET="/opt/cosmos_delphy"
CONFIG_DIR="$DEPLOY_TARGET/config"
TOOLS_DIR="$DEPLOY_TARGET/config/targets/DELPHY/tools"
LOGS_DIR="$DEPLOY_TARGET/config/targets/DELPHY/tools/logs"
BUNDLE_CMD="bundle _1.17.3_ install"

# --------------------------------------------
# FUNCTIONS
# --------------------------------------------

# 1. Setup Deployment Directory
setup_directories() {
    echo "[INFO] Setting up deployment directories..."
    sudo mkdir -p "$DEPLOY_TARGET"
    sudo mkdir -p "$CONFIG_DIR"
    sudo mkdir -p "$TOOLS_DIR"
    sudo mkdir -p "$LOGS_DIR"
    sudo chmod -R 755 "$DEPLOY_TARGET"
    echo "[INFO] Deployment directories created successfully."
}

# 2. Copy Files to Deployment Directory
copy_files() {
    echo "[INFO] Copying configuration and tool files..."
    sudo cp -r config/* "$CONFIG_DIR/"
    sudo cp -r lib/* "$DEPLOY_TARGET/lib/"
    sudo cp -r config/targets/DELPHY/tools/* "$TOOLS_DIR/"
    echo "[INFO] Files copied successfully."
}

# 3. Install Dependencies
install_dependencies() {
    echo "[INFO] Installing dependencies..."
    cd "$DEPLOY_TARGET"
    sudo gem install bundler -v 1.17.3
    sudo $BUNDLE_CMD
    echo "[INFO] Dependencies installed successfully."
}

# 4. Validate Deployment
validate_deployment() {
    echo "[INFO] Validating deployment..."
    cd "$DEPLOY_TARGET"
    ruby -v
    bundle -v
    echo "[INFO] Validation complete. Environment is ready."
}

# 5. Start COSMOS Services
start_services() {
    echo "[INFO] Starting COSMOS Command and Telemetry Server..."
    cd "$DEPLOY_TARGET"
    ruby tools/cmd_tlm_server.rb &
    echo "[INFO] COSMOS Command and Telemetry Server started successfully."
}

# 6. Run Integration Tests
run_tests() {
    echo "[INFO] Running integration tests..."
    cd "$DEPLOY_TARGET"
    bundle exec rspec tests/targets/DELPHY/integration_test.rb --format documentation
    echo "[INFO] Integration tests completed successfully."
}

# 7. Finalize Deployment
finalize() {
    echo "[INFO] Deployment completed successfully."
    echo "[INFO] Logs available at $LOGS_DIR"
}

# --------------------------------------------
# MAIN EXECUTION
# --------------------------------------------

echo "[INFO] Starting DELPHY Deployment..."

setup_directories
copy_files
install_dependencies
validate_deployment
start_services
run_tests
finalize

echo "[INFO] DELPHY Deployment Finished Successfully!"
