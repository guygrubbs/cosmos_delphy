# **DELPHY COSMOS v4 Deployment**

**Version:** 1.0.2  
**Last Updated:** 2024-12-30  
**Maintainer:** DELPHY Operations Team  
**Support Contact:** [guygrubbs@gmail.com](mailto:guygrubbs@gmail.com)  

---

## **1. Introduction**

Welcome to the **DELPHY COSMOS v4 Deployment Repository**. This repository contains all necessary **tools**, **configurations**, and **documentation** required for integrating the **DELPHY System** into the **COSMOS v4 framework**. COSMOS provides advanced capabilities for **command execution**, **telemetry monitoring**, **error handling**, and **workflow automation** in embedded systems.

---

## **2. System Overview**

### **2.1 Key Components**

- **Command Execution:** Interface for sending and managing DELPHY system commands.  
- **Telemetry Monitoring:** Real-time telemetry data collection and validation.  
- **Diagnostics:** Regular system health checks and alerts.  
- **Workflow Automation:** Predefined procedures for recurring tasks.  
- **Error Handling:** Proactive error detection and alert escalation.  
- **Security:** Authentication, encryption, and IP-based access controls.  

### **2.2 Architecture Overview**

- **Communication Interfaces:** TCP/IP and Serial (fallback).  
- **Configuration Files:** Centralized settings for commands, telemetry, and error handling.  
- **Logging:** Structured logging with rotation and alert integration.  
- **Caching:** Telemetry caching with Redis/Memcached.  
- **Monitoring:** Automated system health checks and validation workflows.  

---

## **3. Directory Structure**

The repository follows the **COSMOS v4 recommended directory layout**:

```plaintext
C:.
│   Gemfile          # Ruby dependencies
│   README.md        # Deployment documentation
│
├───.vscode          # Development environment settings
│       launch.json
│
├───config           # Main COSMOS configuration directory
│   ├───logs         # System and tool logs
│   │       cosmos.log
│   │       delphy_tool.log
│   │       telemetry.log
│   │
│   ├───procedures   # Automation and diagnostic procedures
│   │       delphy_maintenance.rb
│   │       delphy_script.rb
│   │       delphy_test_run.rb
│   │       delphy_validation_procedure.rb
│   │
│   ├───system       # System-wide configurations
│   │       system.txt
│   │       targets.txt
│   │       tools.txt
│   │
│   ├───targets      # Target-specific configurations
│   │   └───DELPHY
│   │       │   config.txt
│   │       │   defaults.txt
│   │       │   interfaces.txt
│   │       │   metadata.txt
│   │       │   monitors.txt
│   │       │
│   │       ├───cmd_tlm        # Command and telemetry definitions
│   │       │       commands.txt
│   │       │       telemetry.txt
│   │       │
│   │       ├───documentation  # Documentation files
│   │       │       command_reference.md
│   │       │       DELPHY_User_Manual.pdf
│   │       │       PCS_Network_Specification.pdf
│   │       │
│   │       ├───logs           # Target-specific logs
│   │       │       ack.log
│   │       │       complete.log
│   │       │       delphy.log
│   │       │
│   │       └───procedures     # Target-specific procedures
│   │               delphy_procedure_1.rb
│   │               delphy_procedure_2.rb
│   │               delphy_test_procedure.rb
│   │
│   └───tools
│       └───delphy_tool        # DELPHY-specific tools
│           │   delphy_script.rb
│           │   delphy_tool_gui.rb
│           │   delphy_tool_logger.rb
│           │   delphy_tool_test.rb
│           │
│           └───configs        # Tool configurations
│                   log_levels.yml
│                   tool_config.json
│                   tool_defaults.yml
│
├───lib             # Shared libraries
│       delphy_constants.rb
│       delphy_errors.rb
│       delphy_helper.rb
│       delphy_packet_parser.rb
│       delphy_tool.rb
```

---

## **4. Installation**

### **4.1 Clone the Repository**

```bash
git clone https://github.com/guygrubbs/cosmos_delphy.git
cd cosmos_delphy
```

### **4.2 Install Dependencies**

```bash
gem install bundler
bundle install
```

### **4.3 Configure COSMOS**

```bash
cp -r config/* /path/to/cosmos/config/
```

### **4.4 Environment Variables**

Create a `.env` file:
```plaintext
DELPHY_INTERFACE=TCPIP
DELPHY_IP=129.162.153.79
DELPHY_PORT=14670
```

### **4.5 Verify Installation**

```bash
ruby tools/ScriptRunner -r config/tools/delphy_tool/delphy_tool_logger.rb
```

Logs:
```plaintext
config/tools/delphy_tool/logs/system.log
```

---

## **5. Use Cases**

### **5.1 Example Script Usage**

```ruby
require 'cosmos'
require 'cosmos/script'

# Run a DELPHY Script
cmd('DELPHY', 'RUN_SCRIPT', 'SCRIPT_ID' => 1, 'PARAMETER' => 123.45)
wait_check('DELPHY METADATA SYSTEM_STATE == "NOMINAL"', 10)
```

### **5.2 Integration in Test Runner**

```ruby
require 'cosmos/tools/test_runner/test'

class DelphyIntegrationTest < Cosmos::Test
  def test_system_reset
    cmd('DELPHY', 'RESET_SYSTEM', 'MODE' => 0, 'REASON' => 'Manual Reset')
    wait_check('DELPHY METADATA SYSTEM_STATE == "NOMINAL"', 10)
  end
end
```

Run:
```bash
ruby config/procedures/delphy_test_run.rb
```

### **5.3 Cache Management**

Clear Cache:
```bash
ruby scripts/cache_manager.rb clear
```

---

## **6. Logging**

- **System Logs:** `config/logs/cosmos.log`  
- **Tool Logs:** `config/tools/delphy_tool/logs/delphy_tool.log`  
- **Telemetry Logs:** `config/logs/telemetry.log`  

---

## **7. Troubleshooting**

- **Connection Issues:** Verify IP (`129.162.153.79`) and Port (`14670`).  
- **Logs:** Inspect `config/logs/cosmos.log`.  
- **Telemetry Check:** Ensure `wait_check` statements are validating telemetry correctly.

---

## **8. Support**

- **Support Team:** [guygrubbs@gmail.com](mailto:guygrubbs@gmail.com)  
- **Operations Team:** [kolton.dieckow@swri.org](mailto:kolton.dieckow@swri.org)  

Report bugs via [GitHub Issues](https://github.com/guygrubbs/cosmos_delphy/issues).  

---

## **9. Contribution Guidelines**

1. Fork the repository.  
2. Create a feature branch: `git checkout -b feature-branch`.  
3. Commit changes: `git commit -m "Add new feature"`.  
4. Submit a pull request.  

---

This **README.md** now includes **directory structure**, **installation steps**, **tool use cases in scripts and tests**, **logging details**, and troubleshooting tips, providing a **comprehensive deployment guide**.