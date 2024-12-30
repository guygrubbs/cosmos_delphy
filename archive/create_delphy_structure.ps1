# create_delphy_structure.ps1
# PowerShell script to create DELPHY directory structure for COSMOS v4 deployment

# Root directory
$root = "C:\Projects\COSMOS_Delphy"

# Directory structure
$structure = @(
    "config\system",
    "config\targets\DELPHY\cmd_tlm",
    "config\targets\DELPHY\procedures",
    "config\targets\DELPHY\logs",
    "config\targets\DELPHY\documentation",
    "config\procedures",
    "config\tools\delphy_tool\configs",
    "config\logs",
    "lib",
    "tools"
)

# Files to create
$files = @{
    "config\system\system.txt" = "System configuration file"
    "config\system\tools.txt" = "Tools configuration file"
    "config\system\targets.txt" = "Targets configuration file"
    "config\targets\DELPHY\interfaces.txt" = "TCP Interface configuration for DELPHY"
    "config\targets\DELPHY\cmd_tlm\commands.txt" = "Commands configuration for DELPHY"
    "config\targets\DELPHY\cmd_tlm\telemetry.txt" = "Telemetry configuration for DELPHY"
    "config\targets\DELPHY\config.txt" = "DELPHY general configuration"
    "config\targets\DELPHY\defaults.txt" = "Default settings for DELPHY"
    "config\targets\DELPHY\metadata.txt" = "Metadata for DELPHY properties"
    "config\targets\DELPHY\monitors.txt" = "Monitors configuration for DELPHY"
    "config\targets\DELPHY\procedures\delphy_procedure_1.rb" = "Procedure 1 script"
    "config\targets\DELPHY\procedures\delphy_procedure_2.rb" = "Procedure 2 script"
    "config\targets\DELPHY\procedures\delphy_test_procedure.rb" = "Test procedure script"
    "config\targets\DELPHY\logs\delphy.log" = "Log file for DELPHY"
    "config\targets\DELPHY\logs\ack.log" = "ACK log file"
    "config\targets\DELPHY\logs\complete.log" = "COMPLETE log file"
    "config\targets\DELPHY\documentation\PCS_Network_Specification.pdf" = "Network Specification Document"
    "config\targets\DELPHY\documentation\DELPHY_User_Manual.pdf" = "User Manual Document"
    "config\targets\DELPHY\documentation\command_reference.md" = "Command Reference Document"
    "config\procedures\delphy_script.rb" = "Procedure script for DELPHY"
    "config\procedures\delphy_validation_procedure.rb" = "Validation Procedure"
    "config\procedures\delphy_maintenance.rb" = "Maintenance Procedure"
    "config\procedures\delphy_test_run.rb" = "Test Run Procedure"
    "config\tools\delphy_tool\delphy_script.rb" = "Tool script for DELPHY"
    "config\tools\delphy_tool\delphy_tool_gui.rb" = "GUI script for DELPHY"
    "config\tools\delphy_tool\delphy_tool_logger.rb" = "Logger script for DELPHY"
    "config\tools\delphy_tool\delphy_tool_test.rb" = "Tool test script"
    "config\tools\delphy_tool\configs\tool_config.json" = "Tool configuration JSON"
    "config\tools\delphy_tool\configs\tool_defaults.yml" = "Tool default settings"
    "config\tools\delphy_tool\configs\log_levels.yml" = "Log levels configuration"
    "config\logs\cosmos.log" = "Global COSMOS log"
    "config\logs\delphy_tool.log" = "Tool-specific log for DELPHY"
    "config\logs\telemetry.log" = "Telemetry log"
    "lib\delphy_tool.rb" = "Core DELPHY tool class"
    "lib\delphy_helper.rb" = "Helper functions for DELPHY"
    "lib\delphy_constants.rb" = "Constants for DELPHY"
    "lib\delphy_errors.rb" = "Error definitions for DELPHY"
    "lib\delphy_packet_parser.rb" = "Packet parser for DELPHY"
    "README.md" = "Project README"
    "Gemfile" = "Gem dependencies"
}

# Create directories
Write-Host "Creating directory structure..."
foreach ($dir in $structure) {
    $path = Join-Path -Path $root -ChildPath $dir
    if (-not (Test-Path -Path $path)) {
        New-Item -Path $path -ItemType Directory -Force | Out-Null
        Write-Host "Created directory: $path"
    }
}

# Create files
Write-Host "Creating files..."
foreach ($file in $files.Keys) {
    $filePath = Join-Path -Path $root -ChildPath $file
    if (-not (Test-Path -Path $filePath)) {
        New-Item -Path $filePath -ItemType File -Force | Out-Null
        Add-Content -Path $filePath -Value $files[$file]
        Write-Host "Created file: $filePath"
    }
}

Write-Host "DELPHY directory structure and initial files have been created successfully."
